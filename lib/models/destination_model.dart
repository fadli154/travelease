import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationModel {
  const DestinationModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.category,
    this.ticketPrice = 0,
    this.createdAt,
  });

  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final double rating;
  final String category;
  final double ticketPrice;
  final DateTime? createdAt;

  factory DestinationModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final ratingRaw = data['rating'];
    final priceRaw = data['ticketPrice'];
    final createdAtRaw = data['createdAt'];

    return DestinationModel(
      id: id,
      name: (data['name'] ?? '') as String,
      location: (data['location'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      rating: ratingRaw is num ? ratingRaw.toDouble() : 0.0,
      category: (data['category'] ?? '') as String,
      ticketPrice: priceRaw is num ? priceRaw.toDouble() : 0.0,
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'category': category,
      'ticketPrice': ticketPrice,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  DestinationModel copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    double? rating,
    String? category,
    double? ticketPrice,
    DateTime? createdAt,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
