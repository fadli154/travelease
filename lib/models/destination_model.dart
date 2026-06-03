import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationModel {
  const DestinationModel({
    required this.id,
    required this.name,
    required this.locationName,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.latitude = 0,
    this.longitude = 0,
    this.ticketPrice = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.rating = 0,
    this.createdAt,
  });

  final String id;
  final String name;
  final String locationName;
  final String description;
  final String imageUrl;
  final String category;
  final double latitude;
  final double longitude;
  final double ticketPrice;
  final double averageRating;
  final int totalReviews;
  /// Legacy manual rating from admin; use [displayRating] in UI.
  final double rating;
  final DateTime? createdAt;

  double get displayRating =>
      totalReviews > 0 ? averageRating : (averageRating > 0 ? averageRating : rating);

  /// Backward-compatible alias.
  String get location => locationName;

  bool get hasCoordinates => latitude != 0 || longitude != 0;

  factory DestinationModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final avgRaw = data['averageRating'] ?? data['rating'];
    final latRaw = data['latitude'];
    final lngRaw = data['longitude'];
    final createdAtRaw = data['createdAt'];

    return DestinationModel(
      id: id,
      name: (data['name'] ?? '') as String,
      locationName: ((data['locationName'] ?? data['location']) ?? '') as String,
      description: (data['description'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      category: (data['category'] ?? '') as String,
      latitude: latRaw is num ? latRaw.toDouble() : 0,
      longitude: lngRaw is num ? lngRaw.toDouble() : 0,
      ticketPrice: (data['ticketPrice'] is num)
          ? (data['ticketPrice'] as num).toDouble()
          : 0,
      averageRating: avgRaw is num ? avgRaw.toDouble() : 0,
      totalReviews: (data['totalReviews'] is num)
          ? (data['totalReviews'] as num).toInt()
          : 0,
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0,
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : null,
    );
  }

  Map<String, dynamic> toMap({bool includeCreatedAt = true}) {
    final map = <String, dynamic>{
      'name': name,
      'locationName': locationName,
      'location': locationName,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'ticketPrice': ticketPrice,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'rating': averageRating > 0 ? averageRating : rating,
    };
    if (includeCreatedAt) {
      map['createdAt'] = createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp();
    }
    return map;
  }

  DestinationModel copyWith({
    String? id,
    String? name,
    String? locationName,
    String? description,
    String? imageUrl,
    String? category,
    double? latitude,
    double? longitude,
    double? ticketPrice,
    double? averageRating,
    int? totalReviews,
    double? rating,
    DateTime? createdAt,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      locationName: locationName ?? this.locationName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
