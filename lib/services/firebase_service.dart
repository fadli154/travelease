import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/constants/firestore_collections.dart';
import '../models/destination_model.dart';
import '../models/favorite_model.dart';

class FirebaseService {
  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _destinations =>
      _firestore.collection(FirestoreCollections.destinations);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  CollectionReference<Map<String, dynamic>> get _favorites =>
      _firestore.collection(FirestoreCollections.favorites);

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
    final data = destination.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    final ref = await _destinations.add(data);
    return ref.id;
  }

  Future<void> updateDestination(DestinationModel destination) async {
    final data = destination.toMap();
    data.remove('createdAt');
    await _destinations.doc(destination.id).update(data);
  }

  Future<void> deleteDestination(String id) async {
    await _destinations.doc(id).delete();
  }

  Future<String> uploadDestinationImage({
    required File imageFile,
    required String destinationId,
  }) async {
    final ref = _storage
        .ref()
        .child('destinations')
        .child('$destinationId.jpg');
    final task = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  Future<void> updateDestinationImageUrl(String id, String imageUrl) async {
    await _destinations.doc(id).update({'imageUrl': imageUrl});
  }

  // ── Favorites (userId + destinationId) ─────────────────────────────────────

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
    return _favorites
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final favorites = snapshot.docs
          .map((doc) => FavoriteModel.fromMap(id: doc.id, data: doc.data()))
          .toList();
      favorites.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return favorites;
    });
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

  // ── Admin stats ──────────────────────────────────────────────────────────────

  Future<int> getDestinationCount() async {
    final snapshot = await _destinations.count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getUserCount() async {
    final snapshot = await _users.count().get();
    return snapshot.count ?? 0;
  }
}
