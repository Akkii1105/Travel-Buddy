import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class BuddyPassViewer extends StatelessWidget {
  final String tripId;
  // In a real app, you'd fetch trip and passenger details using tripId

  const BuddyPassViewer({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final tripDetails = {
      'route': 'IITK → Delhi Airport',
      'date': 'Tomorrow, 8:00 AM',
      'status': 'Confirmed',
    };
    final passengers = [
      {'name': 'John Doe', 'contact': '98XXXXXX12'},
      {'name': 'Priya Singh', 'contact': '99XXXXXX34'},
      {'name': 'Amit Kumar', 'contact': '97XXXXXX56'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Buddy Pass')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Trip Details
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      tripDetails['route']!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      tripDetails['date']!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tripDetails['status']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32, thickness: 1),
                // Passenger Details
                Text(
                  'Passengers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...passengers.map((p) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                        child: Text(
                          p['name']![0],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(p['name']!),
                      subtitle: Text('Contact: ${p['contact']}'),
                    )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Download PDF',
                        icon: Icons.picture_as_pdf,
                        onPressed: () {
                          // Download PDF logic
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Share',
                        icon: Icons.share,
                        isOutlined: true,
                        onPressed: () {
                          // Share logic
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 