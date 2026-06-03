import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_collections.dart';
import '../models/destination_model.dart';
import '../models/favorite_model.dart';
import '../models/review_model.dart';
import '../utils/image_helper.dart';

class FirebaseService {
  FirebaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _destinations =>
      _firestore.collection(FirestoreCollections.destinations);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _favorites =>
      _firestore.collection(FirestoreCollections.favorites);

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection(FirestoreCollections.reviews);

  // ── Destinations ─────────────────────────────────────────────────────────────

  Stream<List<DestinationModel>> getDestinations() {
    return _destinations.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => DestinationModel.fromMap(id: doc.id, data: doc.data()))
          .toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  Future<DestinationModel?> getDestinationById(String id) async {
    final doc = await _destinations.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return DestinationModel.fromMap(id: doc.id, data: doc.data()!);
  }

  Future<String> addDestination(DestinationModel destination) async {
    final data = Map<String, dynamic>.from(destination.toMap());
    data['imageUrl'] = ImageHelper.destinationDisplayUrl(
      destination.imageUrl,
      seed: destination.name,
    );
    final ref = await _destinations.add(data);
    return ref.id;
  }

  Future<void> updateDestination(DestinationModel destination) async {
    final data = destination.toMap(includeCreatedAt: false);
    data['imageUrl'] = ImageHelper.destinationDisplayUrl(
      destination.imageUrl,
      seed: destination.id.isNotEmpty ? destination.id : destination.name,
    );
    await _destinations.doc(destination.id).update(data);
  }

  Future<void> deleteDestination(String id) async {
    await _destinations.doc(id).delete();
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isEmpty) return;
    await _users.doc(userId).update(data);
  }

  // ── Favorites ────────────────────────────────────────────────────────────────

  String _favoriteDocId(String userId, String destinationId) =>
      FavoriteModel.docId(userId, destinationId);

  Stream<bool> isFavorite(String userId, String destinationId) {
    if (userId.isEmpty) return Stream.value(false);
    return _favorites
        .doc(_favoriteDocId(userId, destinationId))
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<List<FavoriteModel>> getFavorites(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _favorites.where('userId', isEqualTo: userId).snapshots().map(
      (snapshot) {
        final favorites = snapshot.docs
            .map((doc) => FavoriteModel.fromMap(id: doc.id, data: doc.data()))
            .toList();
        favorites.sort((a, b) {
          final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });
        return favorites;
      },
    );
  }

  Stream<List<DestinationModel>> getFavoriteDestinations(String userId) {
    return getFavorites(userId).asyncMap((favorites) async {
      if (favorites.isEmpty) return <DestinationModel>[];
      final destinations = <DestinationModel>[];
      for (final favorite in favorites) {
        final destination = await getDestinationById(favorite.destinationId);
        if (destination != null) destinations.add(destination);
      }
      return destinations;
    });
  }

  Future<void> addFavorite(String userId, String destinationId) async {
    await _favorites.doc(_favoriteDocId(userId, destinationId)).set({
      'userId': userId,
      'destinationId': destinationId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String userId, String destinationId) async {
    await _favorites.doc(_favoriteDocId(userId, destinationId)).delete();
  }

  Future<void> toggleFavorite(
    String userId,
    String destinationId, {
    required bool currentlyFavorite,
  }) async {
    if (currentlyFavorite) {
      await removeFavorite(userId, destinationId);
    } else {
      await addFavorite(userId, destinationId);
    }
  }

  // ── Reviews ──────────────────────────────────────────────────────────────────

  Stream<List<ReviewModel>> getReviewsForDestination(String destinationId) {
    return _reviews
        .where('destinationId', isEqualTo: destinationId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ReviewModel.fromMap(id: doc.id, data: doc.data()))
          .toList();
      list.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  Future<String> addReview(ReviewModel review) async {
    final ref = await _reviews.add(review.toMap());
    await recalculateDestinationRating(review.destinationId);
    return ref.id;
  }

  Future<void> updateReview(ReviewModel review) async {
    await _reviews.doc(review.id).update(review.toUpdateMap());
    await recalculateDestinationRating(review.destinationId);
  }

  Future<void> deleteReview({
    required String reviewId,
    required String destinationId,
  }) async {
    await _reviews.doc(reviewId).delete();
    await recalculateDestinationRating(destinationId);
  }

  Future<void> recalculateDestinationRating(String destinationId) async {
    final snapshot = await _reviews
        .where('destinationId', isEqualTo: destinationId)
        .get();

    if (snapshot.docs.isEmpty) {
      await _destinations.doc(destinationId).update({
        'averageRating': 0,
        'totalReviews': 0,
        'rating': 0,
      });
      return;
    }

    var sum = 0.0;
    for (final doc in snapshot.docs) {
      final r = doc.data()['rating'];
      if (r is num) sum += r.toDouble();
    }
    final count = snapshot.docs.length;
    final average = sum / count;

    await _destinations.doc(destinationId).update({
      'averageRating': average,
      'totalReviews': count,
      'rating': average,
    });
  }

  // ── Admin stats ──────────────────────────────────────────────────────────────

  Future<int> getDestinationCount() async {
    final snapshot = await _destinations.count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getUserCount() async {
    final snapshot = await _users.count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getReviewCount() async {
    final snapshot = await _reviews.count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getFavoriteCount() async {
    final snapshot = await _favorites.count().get();
    return snapshot.count ?? 0;
  }

  /// Category name → destination count (for admin charts).
  Future<Map<String, int>> getCategoryDistribution() async {
    final snapshot = await _destinations.get();
    final counts = <String, int>{};
    for (final doc in snapshot.docs) {
      final raw = doc.data()['category'];
      final category = raw is String && raw.trim().isNotEmpty
          ? raw.trim()
          : 'Other';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<ReviewModel>> getRecentReviews({int limit = 8}) async {
    final snapshot = await _reviews.get();
    final list = snapshot.docs
        .map((doc) => ReviewModel.fromMap(id: doc.id, data: doc.data()))
        .toList();
    list.sort((a, b) {
      final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bTime.compareTo(aTime);
    });
    return list.take(limit).toList();
  }
}
