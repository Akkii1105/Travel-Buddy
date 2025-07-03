enum TripStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

enum GenderPreference {
  male,
  female,
  other,
}

class Trip {
  final String id;
  final String creatorId;
  final String source;
  final String destination;
  final DateTime departureTime;
  final DateTime? timeRangeStart;
  final DateTime? timeRangeEnd;
  final DateTime createdAt;
  final TripStatus status;
  final GenderPreference genderPreference;
  final List<String> passengerIds;
  final String? telegramGroupLink;
  final String? buddyPassUrl;
  final int maxPassengers;
  final int numberOfBuddies;
  final double estimatedCost;
  final String? notes;

  Trip({
    required this.id,
    required this.creatorId,
    required this.source,
    required this.destination,
    required this.departureTime,
    this.timeRangeStart,
    this.timeRangeEnd,
    required this.createdAt,
    this.status = TripStatus.pending,
    this.genderPreference = GenderPreference.male,
    this.passengerIds = const [],
    this.telegramGroupLink,
    this.buddyPassUrl,
    this.maxPassengers = 4,
    this.numberOfBuddies = 1,
    this.estimatedCost = 0.0,
    this.notes,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      source: json['source'] as String? ?? '',
      destination: json['destination'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      timeRangeStart: json['timeRangeStart'] != null ? DateTime.parse(json['timeRangeStart']) : null,
      timeRangeEnd: json['timeRangeEnd'] != null ? DateTime.parse(json['timeRangeEnd']) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: TripStatus.values.firstWhere(
        (e) => e.toString() == 'TripStatus.${json['status']}',
        orElse: () => TripStatus.pending,
      ),
      genderPreference: GenderPreference.values.firstWhere(
        (e) => e.toString() == 'GenderPreference.${json['genderPreference']}',
        orElse: () => GenderPreference.male,
      ),
      passengerIds: List<String>.from(json['passengerIds'] ?? []),
      telegramGroupLink: json['telegramGroupLink'] as String?,
      buddyPassUrl: json['buddyPassUrl'] as String?,
      maxPassengers: json['maxPassengers'] as int? ?? 4,
      numberOfBuddies: json['numberOfBuddies'] as int? ?? 1,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'source': source,
      'destination': destination,
      'departureTime': departureTime.toIso8601String(),
      'timeRangeStart': timeRangeStart?.toIso8601String(),
      'timeRangeEnd': timeRangeEnd?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'genderPreference': genderPreference.toString().split('.').last,
      'passengerIds': passengerIds,
      'telegramGroupLink': telegramGroupLink,
      'buddyPassUrl': buddyPassUrl,
      'maxPassengers': maxPassengers,
      'numberOfBuddies': numberOfBuddies,
      'estimatedCost': estimatedCost,
      'notes': notes,
    };
  }

  Trip copyWith({
    String? id,
    String? creatorId,
    String? source,
    String? destination,
    DateTime? departureTime,
    DateTime? timeRangeStart,
    DateTime? timeRangeEnd,
    DateTime? createdAt,
    TripStatus? status,
    GenderPreference? genderPreference,
    List<String>? passengerIds,
    String? telegramGroupLink,
    String? buddyPassUrl,
    int? maxPassengers,
    int? numberOfBuddies,
    double? estimatedCost,
    String? notes,
  }) {
    return Trip(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      timeRangeStart: timeRangeStart ?? this.timeRangeStart,
      timeRangeEnd: timeRangeEnd ?? this.timeRangeEnd,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      genderPreference: genderPreference ?? this.genderPreference,
      passengerIds: passengerIds ?? this.passengerIds,
      telegramGroupLink: telegramGroupLink ?? this.telegramGroupLink,
      buddyPassUrl: buddyPassUrl ?? this.buddyPassUrl,
      maxPassengers: maxPassengers ?? this.maxPassengers,
      numberOfBuddies: numberOfBuddies ?? this.numberOfBuddies,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      notes: notes ?? this.notes,
    );
  }

  bool get isFull => passengerIds.length >= maxPassengers;
  bool get isUpcoming => departureTime.isAfter(DateTime.now());
  bool get isPast => departureTime.isBefore(DateTime.now());
  int get availableSeats => maxPassengers - passengerIds.length;
} 