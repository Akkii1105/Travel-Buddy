import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../services/trip_service.dart';
import '../../widgets/custom_button.dart';
import 'trip_detail_screen.dart';
import 'create_trip_screen.dart';
import 'package:lottie/lottie.dart';

class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedSource;
  String? _selectedDestination;
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  final List<String> _popularSources = [
    'IIT Kanpur',
    'Kanpur Central',
    'Lucknow Airport',
    'Delhi Airport',
    'Mumbai Airport',
  ];

  final List<String> _popularDestinations = [
    'IIT Kanpur',
    'Kanpur Central',
    'Lucknow Airport',
    'Delhi Airport',
    'Mumbai Airport',
  ];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await TripService.getTrips(
        source: _selectedSource,
        destination: _selectedDestination,
      );

      setState(() {
        _trips = List<Map<String, dynamic>>.from(response['trips']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTrips() {
    setState(() {
      _trips = _trips.where((trip) {
        final source = trip['source']?.toString().toLowerCase() ?? '';
        final destination = trip['destination']?.toString().toLowerCase() ?? '';
        final title = trip['title']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        final sourceMatch = _selectedSource == null || source.contains(_selectedSource!.toLowerCase());
        final destinationMatch = _selectedDestination == null || destination.contains(_selectedDestination!.toLowerCase());
        return (source.contains(query) || destination.contains(query) || title.contains(query)) && sourceMatch && destinationMatch;
      }).toList();
    });
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced filter card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  // Date & Time Range Pickers
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimeField(
                          'End Date & Time',
                          _endDateTime,
                          () => _selectDateTime(context, false),
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick filters
                  Row(
                    children: [
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return _popularSources;
                            }
                            return _popularSources.where((String option) {
                              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            setState(() {
                              _selectedSource = selection;
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            controller.text = _selectedSource ?? '';
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'From',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.18),
                                    width: 1.2,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.06),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSource = value.isEmpty ? null : value;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return _popularDestinations;
                            }
                            return _popularDestinations.where((String option) {
                              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            setState(() {
                              _selectedDestination = selection;
                            });
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            controller.text = _selectedDestination ?? '';
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'To',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide(
                                    color: AppColors.primary.withOpacity(0.18),
                                    width: 1.2,
                                  ),
                                ),
                                filled: true,
                                fillColor: AppColors.primary.withOpacity(0.06),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDestination = value.isEmpty ? null : value;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _loadTrips();
                      },
                      icon: const Icon(Icons.search, size: 22),
                      label: const Text('Search Trips'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.1, end: 0),
          ),
          // Trips list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load trips',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTrips,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _trips.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: Lottie.asset('assets/animations/empty_trips.json', repeat: true, fit: BoxFit.contain, errorBuilder: (context, error, stack) => Icon(Icons.emoji_people, size: 64, color: AppColors.primary)),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No trips yet! 🚗',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the pioneer! Start a trip and let others join your journey.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You could be the first to create a legendary college trip! 🌟',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTrips,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _trips.length,
                              itemBuilder: (context, index) {
                                final trip = _trips[index];
                                return _buildTripCard(trip, index);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTripScreen()),
          ).then((value) {
            if (value == true) _loadTrips();
          });
        },
        icon: Icon(Icons.add),
        label: Text('Create Trip'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, int index) {
    final source = trip['source'] ?? 'Unknown';
    final destination = trip['destination'] ?? 'Unknown';
    final creatorName = trip['creator_name'] ?? 'Unknown';
    final creatorCollege = trip['creator_college'] ?? 'Unknown';
    final availableSeats = trip['available_seats'] ?? 0;
    final currentParticipants = trip['current_participants'] ?? 0;
    final departureTime = DateTime.tryParse(trip['departure_time'] ?? '');
    final description = trip['description'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailScreen(tripId: trip['id'].toString()),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.arrow_downward,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          destination,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Seats info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${availableSeats - currentParticipants} seats left',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Creator info
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      creatorName.isNotEmpty ? creatorName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creatorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          creatorCollege,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              // Time info
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    departureTime != null
                        ? '${departureTime.day}/${departureTime.month}/${departureTime.year} at ${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}'
                        : 'Time not specified',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms, duration: 400.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primary.withOpacity(0.18), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
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
} 