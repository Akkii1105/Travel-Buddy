import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/searchable_college_dropdown.dart';
import '../../services/auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedCollege;
  Timer? _debounce;

  final List<String> _colleges = [
    'IIT Bombay',
    'IIT Delhi',
    'IIT Kanpur',
    'IIT Kharagpur',
    'IIT Madras',
    'IIT Roorkee',
    'NIT Trichy',
    'NIT Surathkal',
    'BITS Pilani',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _selectedCollege = user['college'] ?? '';
      });
    }
  }

  void _openAvatarCustomizer() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Customize Avatar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: FluttermojiCustomizer(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateProfile(avatar: await FluttermojiFunctions().encodeMySVGtoString());
                setState(() {}); // Refresh avatar after customization
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile({String? name, String? avatar}) async {
    final college = _selectedCollege;
    final newName = name ?? _nameController.text.trim();
    if (newName.isEmpty || college == null || college.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and college are required.'), backgroundColor: AppColors.error),
      );
      return;
    }
    try {
      await AuthService.updateProfile(name: newName, college: college, avatar: avatar);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  FluttermojiCircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _openAvatarCustomizer,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomInputField(
              label: 'Name',
              controller: _nameController,
              prefixIcon: Icons.person,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 800), () async {
                  await _updateProfile(name: value);
                });
              },
            ),
            const SizedBox(height: 20),
            SearchableCollegeDropdown(
              value: _selectedCollege,
              colleges: _colleges,
              onChanged: (value) {
                setState(() {
                  _selectedCollege = value;
                });
              },
              isRequired: true,
            ),
            const SizedBox(height: 20),
            CustomInputField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              enabled: false,
              suffixIcon: Icons.lock,
            ),
            const SizedBox(height: 32),
            // Custom Light/Dark Toggle
            Center(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  final isDark = themeProvider.isDarkMode;
                  return GestureDetector(
                    onTap: () {
                      themeProvider.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      width: 110,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181A20) : const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                          child: isDark
                              ? Row(
                                  key: const ValueKey('dark'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1976D2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.nightlight_round,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Dark',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  key: const ValueKey('light'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFE082),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.wb_sunny_rounded,
                                        color: Color(0xFFFFC107),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Light',
                                      style: TextStyle(
                                        color: Color(0xFF7B1FA2),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Send Feedback',
              icon: Icons.feedback,
              onPressed: () {
                // Feedback logic
              },
              isOutlined: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Logout',
              icon: Icons.logout,
              onPressed: () async {
                try {
                  await AuthService.logout();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
} 