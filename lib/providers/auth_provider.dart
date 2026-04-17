import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state for the app
enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  recovery,
  needsRole,
}

/// Provider for authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isStudent => _user?.role == UserRole.student;
  bool get isOwner => _user?.role == UserRole.owner;
  bool get isAdmin => _user?.role == UserRole.admin;

  /// Initialize auth state listener
  Future<void> initialize() async {
    _authService.authStateChanges.listen((authState) async {
      final event = authState.event;
      final session = authState.session;
      final user = session?.user;

      if (event == AuthChangeEvent.passwordRecovery) {
        _status = AuthStatus.recovery;
      } else if (user == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        _user = await _authService.getUserModel(user.id);
        if (_user == null) {
          _status = AuthStatus.unauthenticated;
        } else if (_user!.role == null) {
          _status = AuthStatus.needsRole;
        } else {
          _status = AuthStatus.authenticated;
        }
      }
      notifyListeners();
    });
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
      );
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in existing user
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile({String? displayName, String? phoneNumber}) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateProfile(
        uid: _user!.uid,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );

      _user = _user!.copyWith(
        displayName: displayName ?? _user!.displayName,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update password (used during recovery flow)
  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updatePassword(newPassword);
      _status =
          AuthStatus.authenticated; // Switch to authenticated after update
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      // On Web/Mobile, this usually causes a redirect or popup.
      // Success will be handled by the authStateChanges listener.
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set the user role (used during initial role selection)
  Future<bool> setUserRole(UserRole role) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateProfile(uid: _user!.uid, role: role);
      _user = _user!.copyWith(role: role);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
