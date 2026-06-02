import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.destinationId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String destinationId;
  final DateTime? createdAt;

  factory FavoriteModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final createdAtRaw = data['createdAt'];

    return FavoriteModel(
      id: id,
      userId: (data['userId'] ?? '') as String,
      destinationId: (data['destinationId'] ?? '') as String,
      createdAt: createdAtRaw is Timestamp ? createdAtRaw.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'destinationId': destinationId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static String docId(String userId, String destinationId) =>
      '${userId}_$destinationId';
}
