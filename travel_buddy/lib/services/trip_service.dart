import 'api_service.dart';

class TripService {
  // Create a new trip
  static Future<Map<String, dynamic>> createTrip({
    required String source,
    required String destination,
    required DateTime departureTime,
    required int availableSeats,
    required String description,
  }) async {
    try {
      final response = await ApiService.post('/trips', {
        'source': source,
        'destination': destination,
        'departureTime': departureTime.toIso8601String(),
        'availableSeats': availableSeats,
        'description': description,
      });

      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get all trips (with optional filters)
  static Future<Map<String, dynamic>> getTrips({
    String? source,
    String? destination,
    DateTime? departureDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (source != null) queryParams['source'] = source;
      if (destination != null) queryParams['destination'] = destination;
      if (departureDate != null) {
        queryParams['departureDate'] = departureDate.toIso8601String().split('T')[0];
      }

      String endpoint = '/trips';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint += '?$queryString';
      }

      final response = await ApiService.get(endpoint);
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get user's own trips
  static Future<Map<String, dynamic>> getMyTrips() async {
    try {
      final response = await ApiService.get('/trips/my');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get trip details by ID
  static Future<Map<String, dynamic>> getTripById(String tripId) async {
    try {
      final response = await ApiService.get('/trips/$tripId');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Cancel a trip
  static Future<Map<String, dynamic>> cancelTrip(String tripId) async {
    try {
      final response = await ApiService.delete('/trips/$tripId');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Join a trip
  static Future<Map<String, dynamic>> joinTrip(String tripId) async {
    try {
      final response = await ApiService.post('/trips/$tripId/join', {});
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Leave a trip
  static Future<Map<String, dynamic>> leaveTrip(String tripId) async {
    try {
      final response = await ApiService.post('/trips/$tripId/leave', {});
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get trip matches (smart matching)
  static Future<Map<String, dynamic>> getTripMatches() async {
    try {
      final response = await ApiService.get('/trips/matches');
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Update trip details
  static Future<Map<String, dynamic>> updateTrip({
    required String tripId,
    String? source,
    String? destination,
    DateTime? departureTime,
    int? availableSeats,
    String? description,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (source != null) updateData['source'] = source;
      if (destination != null) updateData['destination'] = destination;
      if (departureTime != null) updateData['departureTime'] = departureTime.toIso8601String();
      if (availableSeats != null) updateData['availableSeats'] = availableSeats;
      if (description != null) updateData['description'] = description;

      final response = await ApiService.put('/trips/$tripId', updateData);
      return ApiService.parseResponse(response);
    } catch (e) {
      rethrow;
    }
  }
} 