import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/firestore_collections.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  // ── Auth state stream ──────────────────────────────────────────────────────

  /// Emits a [UserModel] whenever the signed-in user changes.
  /// Emits `null` when signed out.
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _fetchUserModel(firebaseUser.uid);
    });
  }

  // ── Current user ───────────────────────────────────────────────────────────

  String? get currentUid => _auth.currentUser?.uid;

  Future<UserModel?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _fetchUserModel(uid);
  }

  // ── Sign in ────────────────────────────────────────────────────────────────

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final user = await _fetchUserModel(uid);
    if (user == null) {
      throw Exception('User profile not found. Please contact support.');
    }
    return user;
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;

    // Update Firebase Auth display name
    await credential.user!.updateDisplayName(name.trim());

    // Create Firestore user document with role "user"
    final userModel = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: UserRole.user,
    );
    await _users.doc(uid).set(userModel.toMap());
    return userModel;
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<UserModel?> _fetchUserModel(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid: uid, data: doc.data()!);
  }
}
