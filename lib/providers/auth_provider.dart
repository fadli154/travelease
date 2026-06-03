import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/auth_error_mapper.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isAuthActionLoading = false;
  String? _error;
  String? _errorDetail;

  StreamSubscription<UserModel?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthActionLoading => _isAuthActionLoading;
  String? get error => _error;
  String? get errorDetail => _errorDetail;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthService get authService => _authService;

  void listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStreamUser,
      onError: (Object e, StackTrace st) {
        AuthErrorMapper.log(e, context: 'authStateChanges');
        if (kDebugMode) debugPrint('[authStateChanges] $st');
      },
    );
  }

  /// Ignores stale stream events (e.g. after logout → login as another user).
  void _onAuthStreamUser(UserModel? user) {
    final firebaseUid = _authService.currentUid;

    if (firebaseUid == null) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (user != null && user.uid == firebaseUid) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_currentUser?.uid == firebaseUid) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = user == null;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(
      () async {
        _currentUser = await _authService.signIn(
          email: email,
          password: password,
        );
      },
      context: 'signIn',
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuthAction(
      () async {
        _currentUser = await _authService.register(
          name: name,
          email: email,
          password: password,
        );
      },
      context: 'register',
    );
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthAction(
      () async {
        _currentUser = await _authService.signInWithGoogle();
      },
      context: 'signInWithGoogle',
    );
  }

  Future<void> signOut() async {
    _isAuthActionLoading = true;
    _error = null;
    _errorDetail = null;
    notifyListeners();
    try {
      await _authService.signOut();
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isAuthActionLoading = false;
      notifyListeners();
    }
  }

  void updateLocalUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _errorDetail = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(
    Future<void> Function() action, {
    required String context,
  }) async {
    _isAuthActionLoading = true;
    _error = null;
    _errorDetail = null;
    notifyListeners();
    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e, st) {
      AuthErrorMapper.log(e, context: context);
      if (kDebugMode) {
        debugPrint('[$context] stack: $st');
      }
      _error = AuthErrorMapper.userMessage(e);
      _errorDetail = AuthErrorMapper.debugMessage(e);
      notifyListeners();
      return false;
    } finally {
      _isAuthActionLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
