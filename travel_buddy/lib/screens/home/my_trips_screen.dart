import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../models/trip.dart';
import '../../services/trip_service.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  List<Trip> _allTrips = [];
  List<Trip> _upcomingTrips = [];
  List<Trip> _pastTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() { _isLoading = true; });
    try {
      final response = await TripService.getMyTrips();
      final tripsJson = response['trips'] as List<dynamic>? ?? [];
      _allTrips = tripsJson.map((json) => Trip.fromJson(json)).toList();
      _filterTrips();
    } catch (e) {
      // Handle error, show snackbar, etc.
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _filterTrips() {
    final now = DateTime.now();
    _upcomingTrips = _allTrips.where((trip) {
      final end = trip.timeRangeEnd ?? trip.departureTime;
      return end.isAfter(now);
    }).toList();
    _pastTrips = _allTrips.where((trip) {
      final end = trip.timeRangeEnd ?? trip.departureTime;
      return end.isBefore(now);
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          tabs: const [
            Tab(text: 'Upcoming Trips'),
            Tab(text: 'Past Trips'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _upcomingTrips.isEmpty
                    ? _buildEmptyState(true)
                    : _buildTripsList(_upcomingTrips, true),
                _pastTrips.isEmpty
                    ? _buildEmptyState(false)
                    : _buildTripsList(_pastTrips, false),
              ],
            ),
    );
  }

  Widget _buildTripsList(List<Trip> trips, bool isUpcoming) {
    if (trips.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(trips[index], index);
      },
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      AppColors.primary.withOpacity(0.18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  isUpcoming ? Icons.flight_takeoff_rounded : Icons.history_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isUpcoming ? 'No Upcoming or Ongoing Trips' : 'No Past Trips Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: 0.1,
                  shadows: isDark ? [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0,2))] : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isUpcoming
                    ? 'Start your next adventure! Create a new trip and find awesome travel buddies.'
                    : 'Your completed journeys will appear here. Keep exploring and making memories!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  shadows: isDark ? [Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0,1))] : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
        ),
        if (isUpcoming)
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, '/new-trip');
                },
                icon: const Icon(Icons.add, size: 28),
                label: const Text(
                  'Create Trip',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                extendedPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTripCard(Trip trip, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Trip Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusColor(trip.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(trip.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(trip.status),
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IITK → ${trip.destination}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(trip.status),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getStatusColor(trip.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(trip.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${trip.estimatedCost.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Trip Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(trip.departureTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${trip.passengerIds.length} passenger${trip.passengerIds.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (trip.availableSeats > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${trip.availableSeats} seat${trip.availableSeats != 1 ? 's' : ''} left',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Action Buttons
                if (trip.status == TripStatus.confirmed) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (trip.telegramGroupLink != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: CustomButton(
                              text: 'Group Chat',
                              onPressed: () {
                                // Open Telegram group
                              },
                              icon: Icons.chat,
                              height: 40,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: CustomButton(
                            text: 'Cancel Trip',
                            onPressed: () {
                              // Cancel trip logic
                            },
                            icon: Icons.cancel,
                            height: 40,
                            isOutlined: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100), duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Color _getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return AppColors.warning;
      case TripStatus.confirmed:
        return AppColors.success;
      case TripStatus.completed:
        return AppColors.info;
      case TripStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return Icons.schedule;
      case TripStatus.confirmed:
        return Icons.check_circle;
      case TripStatus.completed:
        return Icons.done_all;
      case TripStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(TripStatus status) {
    switch (status) {
      case TripStatus.pending:
        return 'Pending Confirmation';
      case TripStatus.confirmed:
        return 'Confirmed';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} from now';
    } else {
      return 'Today at ${TimeOfDay.fromDateTime(dateTime).format(context)}';
    }
  }
} 