import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageTripScreen extends StatelessWidget {
  const ManageTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Trip',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Center(
        child: Text(
          'Manage your trip details here!',
          style: GoogleFonts.inter(
            fontSize: 18,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 