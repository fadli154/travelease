import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.destinationId,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.rating,
    required this.comment,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String destinationId;
  final String userId;
  final String userName;
  final String userPhoto;
  final double rating;
  final String comment;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ReviewModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return ReviewModel(
      id: id,
      destinationId: (data['destinationId'] ?? '') as String,
      userId: (data['userId'] ?? '') as String,
      userName: (data['userName'] ?? '') as String,
      userPhoto: (data['userPhoto'] ?? '') as String,
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0,
      comment: (data['comment'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'destinationId': destinationId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'rating': rating,
      'comment': comment,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'rating': rating,
      'comment': comment,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
