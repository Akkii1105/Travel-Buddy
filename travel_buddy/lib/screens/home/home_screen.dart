import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../screens/trips/trip_list_screen.dart';
import 'my_trips_screen.dart';
import 'manage_trip_screen.dart';
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../services/trip_service.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'dart:ui'; // For ImageFilter
import 'package:fluttermoji/fluttermoji.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";
  String? avatar;
  List<Map<String, dynamic>> _myTrips = [];
  bool _loadingTrips = true;
  final List<Map<String, dynamic>> _dreamDestinations = [
    {'name': 'IIT Bombay', 'image': 'assets/images/iit_bombay.jpg'},
    {'name': 'IIT Delhi', 'image': 'assets/images/iit_delhi.jpg'},
    {'name': 'IIT Kanpur', 'image': 'assets/images/iit_kanpur.jpg'},
    {'name': 'NIT Trichy', 'image': 'assets/images/nit_trichy.jpg'},
    {'name': 'BITS Pilani', 'image': 'assets/images/bits_pilani.jpg'},
    {'name': 'Manali', 'image': 'assets/images/manali.jpg'},
    {'name': 'Goa', 'image': 'assets/images/goa.jpg'},
    {'name': 'Pune', 'image': 'assets/images/pune.jpg'},
    {'name': 'Bangalore', 'image': 'assets/images/bangalore.jpg'},
  ];
  final List<String> _travelQuotes = [
    'The world is a book, and those who do not travel read only one page. — Saint Augustine',
    'Travel is the only thing you buy that makes you richer.',
    'Life is short and the world is wide.',
    'Adventure awaits. Go find it!',
    'To travel is to live. — Hans Christian Andersen',
    'Did you know? The longest flight in the world is over 18 hours!'
  ];
  int _quoteIndex = 0;
  final List<String> _funChallenges = [
    '🚩 Challenge: Plan a trip to a city you\'ve never visited!',
    '🎯 Fun Stat: Students who travel together make lifelong friends.',
    '🏆 Badge: Be the first in your college to create a trip this week!',
    '🌟 Did you know? Group trips save up to 30% on travel costs!',
    '🎒 Try: Organize a weekend getaway with your hostel mates!',
    '🗺️ Explore: Add a new pin to your travel map!',
  ];
  int _challengeIndex = 0;
  double avatarRadius = 28;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMyTrips();
    _startQuoteRotation();
    _challengeIndex = Random().nextInt(_funChallenges.length);
  }

  void _startQuoteRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 6));
      if (!mounted) return false;
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % _travelQuotes.length;
      });
      return true;
    });
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        userName = user['name'] ?? '';
        avatar = user['avatar'];
      });
    }
  }

  Future<void> _loadMyTrips() async {
    setState(() { _loadingTrips = true; });
    try {
      final response = await TripService.getMyTrips();
      setState(() {
        _myTrips = List<Map<String, dynamic>>.from(response['trips'] ?? []);
        _loadingTrips = false;
      });
    } catch (e) {
      setState(() { _loadingTrips = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,  A0${userName.isNotEmpty ? userName : 'Traveler'}!',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                      Text(
                        'Where are you headed today?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2, end: 0),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.18),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(avatarRadius),
                    ),
                    child: FluttermojiCircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(begin: const Offset(0.5, 0.5)),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Trip Summary Card
              if (_loadingTrips) ...[
                const SizedBox(height: 30),
                Center(child: CircularProgressIndicator()),
                const SizedBox(height: 30),
              ] else if (_myTrips.isNotEmpty) ...[
                _buildTripSummaryCard(_myTrips.first),
                const SizedBox(height: 30),
              ] else ...[
                const SizedBox(height: 30),
                _buildCreativeEmptyState(),
                const SizedBox(height: 30),
              ],
              
              const SizedBox(height: 30),
              
              // Quick Actions Section
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              
              const SizedBox(height: 20),
              
              // Quick Action Grid
              _buildQuickActionGrid(),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard(Map<String, dynamic> trip) {
    // If trip is confirmed, show a unique, celebratory card
    final isConfirmed = (trip['status']?.toString().toLowerCase() == 'confirmed');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConfirmed
              ? [Colors.greenAccent.shade100, AppColors.primary]
              : [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isConfirmed) ...[
            Row(
              children: [
                Icon(Icons.celebration, color: Colors.orangeAccent, size: 32),
                const SizedBox(width: 10),
                Text(
                  'Trip Confirmed! 🎉',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Trip',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    letterSpacing: 0.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Confirmed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.textLight,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${trip['from']} → ${trip['to']}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${trip['date']}, ${trip['time']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isConfirmed) ...[
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.share),
                label: const Text('Share with Friends', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    // Navigate to trip details screen
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'View Trip',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildCreativeEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        _InfoCardCarousel(),
        const SizedBox(height: 30),
        // Big action button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Start Planning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.pushNamed(context, '/trips');
          },
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildQuickActionGrid() {
    final actions = [
      {
        'icon': Icons.search,
        'title': 'Find a Trip',
        'color': AppColors.primary,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TripListScreen()),
        ),
      },
      {
        'icon': Icons.chat_bubble,
        'title': 'Group Chat',
        'color': AppColors.info,
        'onTap': () => Navigator.pushNamed(context, '/group-chat'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          icon: action['icon'] as IconData,
          title: action['title'] as String,
          color: action['color'] as Color,
          onTap: action['onTap'] as VoidCallback,
          delay: 800 + (index * 100),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glassmorphism overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: color.withOpacity(0.07),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

class _InfoCardCarousel extends StatefulWidget {
  @override
  State<_InfoCardCarousel> createState() => _InfoCardCarouselState();
}

class _InfoCardCarouselState extends State<_InfoCardCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentIndex + 1) % cards.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<_InfoCardData> get cards {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      _InfoCardData(
        title: 'Find Your Travel Buddy!',
        description: 'Connect with students from your or other colleges and plan trips together.',
        gradient: isDark
            ? LinearGradient(colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400])
            : LinearGradient(colors: [Colors.purple, Colors.deepPurpleAccent]),
        textColor: isDark ? Colors.white : Colors.white,
        descColor: isDark ? Colors.white70 : Colors.white70,
      ),
      _InfoCardData(
        title: 'Safety First',
        description: 'All users are verified students. Travel with peace of mind!',
        gradient: isDark
            ? LinearGradient(colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade600])
            : LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
        textColor: isDark ? Colors.white : Colors.white,
        descColor: isDark ? Colors.white70 : Colors.white70,
      ),
      _InfoCardData(
        title: 'Group Savings',
        description: 'Traveling in groups can save you up to 30% on costs. Try it now!',
        gradient: isDark
            ? LinearGradient(colors: [Colors.orange.shade900, Colors.deepOrange.shade700])
            : LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent]),
        textColor: isDark ? Colors.white : Colors.white,
        descColor: isDark ? Colors.white70 : Colors.white70,
      ),
      _InfoCardData(
        title: 'Fun Challenges',
        description: 'Complete travel challenges and earn badges in the app!',
        gradient: isDark
            ? LinearGradient(colors: [Colors.green.shade900, Colors.teal.shade700])
            : LinearGradient(colors: [Colors.green, Colors.teal]),
        textColor: isDark ? Colors.white : Colors.white,
        descColor: isDark ? Colors.white70 : Colors.white70,
      ),
      _InfoCardData(
        title: 'Stay Notified',
        description: 'Get instant updates about your trips and buddies with push notifications.',
        gradient: isDark
            ? LinearGradient(colors: [Colors.pink.shade900, Colors.red.shade700])
            : LinearGradient(colors: [Colors.pink, Colors.redAccent]),
        textColor: isDark ? Colors.white : Colors.white,
        descColor: isDark ? Colors.white70 : Colors.white70,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
      child: Center(
        child: SizedBox(
          width: size.width * 0.90,
          height: size.height * 0.22,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: cards.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: card.gradient,
                            ),
                          ),
                          // Glassmorphism overlay
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.10)
                                    : Colors.white.withOpacity(0.22),
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.black.withOpacity(0.08),
                                  width: 1.2,
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.title,
                                  style: TextStyle(
                                    color: card.textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    letterSpacing: 0.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  card.description,
                                  style: TextStyle(
                                    color: card.descColor,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w400,
                                    height: 1.35,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.07),
                                        blurRadius: 1,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(cards.length, (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentIndex == index ? 18 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        if (_currentIndex == index)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCardData {
  final String title;
  final String description;
  final Gradient gradient;
  final Color textColor;
  final Color descColor;
  _InfoCardData({required this.title, required this.description, required this.gradient, required this.textColor, required this.descColor});
} 