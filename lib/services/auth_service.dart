import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/config/google_auth_config.dart';
import '../core/constants/firestore_collections.dart';
import '../models/user_model.dart';
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
              serverClientId: GoogleAuthConfig.webClientId,
            );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (kDebugMode) {
        debugPrint('[AuthService] authStateChanges event: firebaseUser=${firebaseUser?.uid}');
      }
      if (firebaseUser == null) return null;
      final uid = firebaseUser.uid;
      final model = await _fetchUserModel(uid);
      if (kDebugMode) {
        debugPrint('[AuthService] authStateChanges fetched model: ${model?.email} (uid: ${model?.uid})');
      }
      if (_auth.currentUser?.uid != uid) {
        if (kDebugMode) {
          debugPrint('[AuthService] authStateChanges uid mismatch: currentUid=${_auth.currentUser?.uid}, eventUid=$uid');
        }
        return null;
      }
      return model;
    });
  }

  Stream<UserModel?> get userChanges {
    return _auth.userChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final uid = firebaseUser.uid;
      return _fetchUserModel(uid);
    });
  }

  String? get currentUid => _auth.currentUser?.uid;

  Future<UserModel?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _fetchUserModel(uid);
  }

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
      throw FirebaseAuthException(
        code: 'profile-not-found',
        message: 'User profile not found in Firestore users/$uid',
      );
    }
    return user;
  }

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
    await credential.user!.updateDisplayName(name.trim());

    final userModel = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      role: UserRole.user,
    );
    await _users.doc(uid).set(userModel.toMap());
    return userModel;
  }

  Future<UserModel> signInWithGoogle() async {
    if (kDebugMode) {
      debugPrint('[AuthService] Starting Google sign-in…');
      debugPrint('[AuthService] serverClientId=${GoogleAuthConfig.webClientId}');
    }

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in cancelled by user');
    }

    if (kDebugMode) {
      debugPrint('[AuthService] Google account: ${googleUser.email}');
    }

    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null) {
      throw Exception(
        'Google ID token is null. Verify Web Client ID (serverClientId) and SHA-1 in Firebase.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Firebase user is null after Google credential',
      );
    }

    final uid = firebaseUser.uid;
    if (kDebugMode) {
      debugPrint('[AuthService] Firebase Auth OK uid=$uid');
    }

    var user = await _fetchUserModel(uid);
    if (user == null) {
      if (kDebugMode) {
        debugPrint('[AuthService] Creating Firestore users/$uid');
      }
      user = UserModel(
        uid: uid,
        name: firebaseUser.displayName?.trim().isNotEmpty == true
            ? firebaseUser.displayName!.trim()
            : 'Traveler',
        email: firebaseUser.email ?? googleUser.email,
        role: UserRole.user,
        photoUrl: firebaseUser.photoURL ?? '',
      );
      await _users.doc(uid).set(user.toMap(), SetOptions(merge: true));
      user = await _fetchUserModel(uid) ?? user;
    } else {
      await _users.doc(uid).set({
        'photoUrl': firebaseUser.photoURL ?? user.photoUrl,
        'name': user.name.isEmpty
            ? (firebaseUser.displayName ?? user.name)
            : user.name,
      }, SetOptions(merge: true));
    }

    if (kDebugMode) {
      debugPrint('[AuthService] Google sign-in complete role=${user.role.name}');
    }
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  Future<UserModel?> _fetchUserModel(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid: uid, data: doc.data()!);
  }
}
