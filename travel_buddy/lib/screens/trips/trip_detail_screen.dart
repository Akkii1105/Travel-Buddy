import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../services/trip_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Map<String, dynamic>? _trip;
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  String? _error;
  bool _isJoining = false;
  bool _isLeaving = false;
  Map<String, dynamic>? _currentUser;
  bool _isCreator = false;
  bool _isParticipant = false;

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadTripDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await TripService.getTripById(widget.tripId);
      final tripData = response['trip'];
      
      setState(() {
        _trip = tripData;
        _participants = List<Map<String, dynamic>>.from(tripData['participants'] ?? []);
        _isLoading = false;
      });

      // Check if current user is creator or participant
      if (_currentUser != null) {
        _isCreator = tripData['creator_id'] == _currentUser!['id'];
        _isParticipant = _participants.any((p) => p['id'] == _currentUser!['id']);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _joinTrip() async {
    try {
      setState(() {
        _isJoining = true;
      });

      await TripService.joinTrip(widget.tripId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined trip!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload trip details to update participant list
        await _loadTripDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join trip: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  Future<void> _leaveTrip() async {
    try {
      setState(() {
        _isLeaving = true;
      });

      await TripService.leaveTrip(widget.tripId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully left trip!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload trip details to update participant list
        await _loadTripDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave trip: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLeaving = false;
        });
      }
    }
  }

  Future<void> _cancelTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trip'),
        content: const Text('Are you sure you want to cancel this trip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TripService.cancelTrip(widget.tripId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip cancelled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel trip: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        actions: [
          if (_isCreator)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelTrip,
              tooltip: 'Cancel Trip',
            ),
        ],
      ),
      body: _isLoading
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
                        'Failed to load trip details',
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
                        onPressed: _loadTripDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _trip == null
                  ? const Center(child: Text('Trip not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trip route card
                          _buildRouteCard(),
                          const SizedBox(height: 20),
                          
                          // Trip details card
                          _buildDetailsCard(),
                          const SizedBox(height: 20),
                          
                          // Participants card
                          _buildParticipantsCard(),
                          const SizedBox(height: 20),
                          
                          // Action buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildRouteCard() {
    final source = _trip!['source'] ?? 'Unknown';
    final destination = _trip!['destination'] ?? 'Unknown';
    final creatorName = _trip!['creator_name'] ?? 'Unknown';
    final creatorCollege = _trip!['creator_college'] ?? 'Unknown';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Route
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        source,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.arrow_downward,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Creator info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    creatorName.isNotEmpty ? creatorName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created by $creatorName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        creatorCollege,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildDetailsCard() {
    final departureTime = DateTime.tryParse(_trip!['departure_time'] ?? '');
    final availableSeats = _trip!['available_seats'] ?? 0;
    final currentParticipants = _participants.length;
    final description = _trip!['description'] ?? '';
    final status = _trip!['status'] ?? 'active';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            // Departure time
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    departureTime != null
                        ? '${departureTime.day}/${departureTime.month}/${departureTime.year} at ${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}'
                        : 'Time not specified',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Seats info
            Row(
              children: [
                Icon(Icons.airline_seat_recline_normal, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$currentParticipants / $availableSeats seats filled',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Status
            Row(
              children: [
                Icon(
                  status == 'active' ? Icons.check_circle : Icons.cancel,
                  color: status == 'active' ? Colors.green : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  status == 'active' ? 'Active' : 'Cancelled',
                  style: TextStyle(
                    fontSize: 16,
                    color: status == 'active' ? Colors.green : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildParticipantsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participants (${_participants.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (_participants.isEmpty)
              Center(
                child: Text(
                  'No participants yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  final participant = _participants[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            participant['name']?.isNotEmpty == true 
                                ? participant['name'][0].toUpperCase() 
                                : '?',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                participant['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                participant['college'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildActionButtons() {
    if (_isCreator) {
      return CustomButton(
        text: 'Cancel Trip',
        onPressed: _cancelTrip,
        isOutlined: true,
      ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms);
    } else if (_isParticipant) {
      return CustomButton(
        text: _isLeaving ? 'Leaving...' : 'Leave Trip',
        onPressed: _isLeaving ? null : _leaveTrip,
        isOutlined: true,
      ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms);
    } else {
      return CustomButton(
        text: _isJoining ? 'Joining...' : 'Join Trip',
        onPressed: _isJoining ? null : _joinTrip,
      ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms);
    }
  }
} 