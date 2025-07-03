import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ChatService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static Function(Map<String, dynamic>)? _onMessageReceived;
  static Function(Map<String, dynamic>)? _onNotificationReceived;

  // Initialize socket connection
  static Future<void> initializeSocket() async {
    if (_socket != null && _isConnected) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    _socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket!.onConnect((_) {
      _isConnected = true;
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('Socket disconnected');
    });

    _socket!.on('message', (data) {
      if (_onMessageReceived != null) {
        _onMessageReceived!(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('notification', (data) {
      if (_onNotificationReceived != null) {
        _onNotificationReceived!(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('match_found', (data) {
      // Handle trip match found
      print('Match found: $data');
    });

    _socket!.connect();
  }

  // Disconnect socket
  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  // Set message received callback
  static void onMessageReceived(Function(Map<String, dynamic>) callback) {
    _onMessageReceived = callback;
  }

  // Set notification received callback
  static void onNotificationReceived(Function(Map<String, dynamic>) callback) {
    _onNotificationReceived = callback;
  }

  // Send message to group chat
  static void sendMessage(String groupId, String message) {
    if (_socket != null && _isConnected) {
      _socket!.emit('send_message', {
        'groupId': groupId,
        'message': message,
      });
    }
  }

  // Join group chat
  static void joinGroup(String groupId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join_group', {'groupId': groupId});
    }
  }

  // Leave group chat
  static void leaveGroup(String groupId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave_group', {'groupId': groupId});
    }
  }

  // Get group chat messages
  static Future<Map<String, dynamic>> getGroupMessages(String groupId) async {
    try {
      final response = await ApiService.get('/chat/groups/$groupId/messages');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get user's group chats
  static Future<Map<String, dynamic>> getGroupChats() async {
    try {
      final response = await ApiService.get('/chat/groups');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Create group chat (for trip matches)
  static Future<Map<String, dynamic>> createGroupChat({
    required String tripId,
    required List<String> memberIds,
  }) async {
    try {
      final response = await ApiService.post('/chat/groups', {
        'tripId': tripId,
        'memberIds': memberIds,
      });
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Register device token for push notifications
  static Future<Map<String, dynamic>> registerDeviceToken(String deviceToken) async {
    try {
      final response = await ApiService.post('/notifications/register', {
        'deviceToken': deviceToken,
      });
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await ApiService.get('/notifications');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Mark notification as read
  static Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    try {
      final response = await ApiService.put('/notifications/$notificationId/read', {});
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Check if socket is connected
  static bool get isConnected => _isConnected;
} 