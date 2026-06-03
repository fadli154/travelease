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
  bool _isDisposed = false;

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
    if (_isDisposed) return;
    
    final firebaseUid = _authService.currentUid;
    if (kDebugMode) {
      debugPrint('[AuthProvider] _onAuthStreamUser: firebaseUid=$firebaseUid, userUid=${user?.uid}');
    }

    if (firebaseUid == null) {
      if (kDebugMode) {
        debugPrint('[AuthProvider] No firebaseUid -> clearing user');
      }
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (user != null && user.uid == firebaseUid) {
      if (kDebugMode) {
        debugPrint('[AuthProvider] Stream user matches firebaseUid: ${user.email}');
      }
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_currentUser?.uid == firebaseUid) {
      if (kDebugMode) {
        debugPrint('[AuthProvider] Existing currentUser matches firebaseUid: ${_currentUser?.email}');
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (kDebugMode) {
      debugPrint('[AuthProvider] Fallthrough: firebaseUid=$firebaseUid. Resolving user directly.');
    }
    
    _fetchAndResolveUser(firebaseUid);
  }

  Future<void> _fetchAndResolveUser(String firebaseUid) async {
    try {
      final user = await _authService.getCurrentUser();
      if (_isDisposed) return;

      if (_authService.currentUid == firebaseUid) {
        if (user != null) {
          if (kDebugMode) {
            debugPrint('[AuthProvider] _fetchAndResolveUser resolved user: ${user.email}');
          }
          _currentUser = user;
        } else {
          if (kDebugMode) {
            debugPrint('[AuthProvider] _fetchAndResolveUser resolved null user, signing out');
          }
          await _authService.signOut();
          _currentUser = null;
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AuthProvider] Error in _fetchAndResolveUser: $e\n$st');
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
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
    if (_isDisposed) return;
    _isAuthActionLoading = true;
    _error = null;
    _errorDetail = null;
    notifyListeners();
    try {
      await _authService.signOut();
      if (!_isDisposed) {
        _currentUser = null;
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _isAuthActionLoading = false;
        notifyListeners();
      }
    }
  }

  void updateLocalUser(UserModel user) {
    if (_isDisposed) return;
    _currentUser = user;
    notifyListeners();
  }

  void clearError() {
    if (_isDisposed) return;
    _error = null;
    _errorDetail = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(
    Future<void> Function() action, {
    required String context,
  }) async {
    if (_isDisposed) return false;
    _isAuthActionLoading = true;
    _error = null;
    _errorDetail = null;
    notifyListeners();
    try {
      await action();
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
      return _currentUser != null;
    } catch (e, st) {
      AuthErrorMapper.log(e, context: context);
      if (kDebugMode) {
        debugPrint('[$context] stack: $st');
      }
      if (!_isDisposed) {
        _error = AuthErrorMapper.userMessage(e);
        _errorDetail = AuthErrorMapper.debugMessage(e);
        notifyListeners();
      }
      return false;
    } finally {
      if (!_isDisposed) {
        _isAuthActionLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
