import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_colors.dart';
import 'custom_button.dart';

class MatchFoundModal extends StatelessWidget {
  final List<Map<String, String>> buddies; // [{name, avatarUrl}]
  final VoidCallback onTelegramTap;
  final VoidCallback onDownloadPass;

  const MatchFoundModal({
    super.key,
    required this.buddies,
    required this.onTelegramTap,
    required this.onDownloadPass,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confetti/Lottie Animation
            SizedBox(
              height: 100,
              child: Lottie.asset(
                'assets/animations/confetti.json',
                repeat: false,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Match Found!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have been matched with:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            // Avatars
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: buddies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final buddy = buddies[index];
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                        backgroundImage: buddy['avatarUrl'] != null && buddy['avatarUrl']!.isNotEmpty
                            ? NetworkImage(buddy['avatarUrl']!)
                            : null,
                        child: buddy['avatarUrl'] == null || buddy['avatarUrl']!.isEmpty
                            ? Text(
                                buddy['name']![0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        buddy['name'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            // Telegram CTA
            CustomButton(
              text: 'Join Telegram Group',
              icon: Icons.telegram,
              onPressed: onTelegramTap,
              height: 48,
            ),
            const SizedBox(height: 16),
            // Download Buddy Pass
            CustomButton(
              text: 'Download Buddy Pass',
              icon: Icons.download,
              onPressed: onDownloadPass,
              isOutlined: true,
              height: 48,
            ),
            const SizedBox(height: 8),
            // Close Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 