import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  // Register user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String college,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'college': college,
      });

      final data = ApiService.parseResponse(response);
      
      // Store token and user data
      if (data['token'] != null) {
        await _saveToken(data['token']);
        await _saveUser(data['user']);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final data = ApiService.parseResponse(response);
      
      // Store token and user data
      if (data['token'] != null) {
        await _saveToken(data['token']);
        await _saveUser(data['user']);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      // Call logout endpoint to invalidate token on server
      await ApiService.post('/auth/logout', {});
    } catch (e) {
      // Even if server call fails, clear local data
    } finally {
      // Clear local storage
      await _clearToken();
      await _clearUser();
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return Map<String, dynamic>.from(
        jsonDecode(userJson),
      );
    }
    return null;
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String college,
    String? avatar,
  }) async {
    try {
      final response = await ApiService.put('/users/profile', {
        'name': name,
        'college': college,
        if (avatar != null) 'avatar': avatar,
      });

      final data = ApiService.parseResponse(response);
      // Update stored user data
      if (data['user'] != null) {
        await _saveUser(data['user']);
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiService.get('/users/profile');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Save token to local storage
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token from local storage
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clear token from local storage
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Save user data to local storage
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // Clear user data from local storage
  static Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
} 