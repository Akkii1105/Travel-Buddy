import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../services/trip_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/searchable_college_dropdown.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({Key? key}) : super(key: key);

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _interestsController = TextEditingController();
  final _sourceController = TextEditingController();
  final _genderPreference = ValueNotifier<String?>('Any');
  int _numberOfBuddies = 1;
  
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  int _maxMembers = 4;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _interestsController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStart) {
            _startDateTime = dateTime;
          } else {
            _endDateTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end date & time')),
      );
      return;
    }

    if (_endDateTime!.isBefore(_startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date/time cannot be before start date/time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await TripService.createTrip(
        source: _sourceController.text,
        destination: _destinationController.text,
        departureTime: _startDateTime!,
        availableSeats: _maxMembers,
        description: _descriptionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create trip: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Trip',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan Your Journey',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 30),
              
              // Trip Title
              CustomInputField(
                controller: _titleController,
                label: 'Trip Title',
                hint: 'Enter a catchy title for your trip',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip title';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 20),
              
              // Source
              CustomInputField(
                controller: _sourceController,
                label: 'Source',
                hint: 'Where are you starting from?',
                prefixIcon: Icons.location_searching,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter source location';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 150.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 20),
              
              // Destination
              CustomInputField(
                controller: _destinationController,
                label: 'Destination',
                hint: 'Where are you going?',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 20),
              
              // Description
              CustomInputField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Tell others about your trip plans',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 20),
              
              // Date & Time Range Selection
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeField(
                      'Start Date & Time',
                      _startDateTime,
                      () => _selectDateTime(context, true),
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildDateTimeField(
                      'End Date & Time',
                      _endDateTime,
                      () => _selectDateTime(context, false),
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 20),
              
              // Max Members
              _buildMaxMembersSelector().animate().fadeIn(delay: 500.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 20),
              
              // Budget
              CustomInputField(
                controller: _budgetController,
                label: 'Budget (Optional)',
                hint: 'Estimated budget per person',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: _isLoading ? 'Creating Trip...' : 'Create Trip',
            onPressed: _isLoading ? null : _createTrip,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
    String label,
    DateTime? selectedDateTime,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.18), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedDateTime != null
                        ? '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year}  ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}'
                        : 'Select date & time',
                    style: TextStyle(
                      color: selectedDateTime != null ? AppColors.textPrimary : Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxMembersSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Buddies',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.people, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$_maxMembers buddies',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _maxMembers > 2 ? () => setState(() => _maxMembers--) : null,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: _maxMembers > 2 ? AppColors.primary : Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    '$_maxMembers',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _maxMembers < 10 ? () => setState(() => _maxMembers++) : null,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: _maxMembers < 10 ? AppColors.primary : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 