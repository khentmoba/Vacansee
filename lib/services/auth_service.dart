import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AppAuthException implements Exception {
  final String message;
  const AppAuthException(this.message);

  factory AppAuthException.fromSupabase(AuthException e) {
    String message = e.message;
    try {
      // Supabase sometimes returns error messages as raw JSON strings.
      final decoded = jsonDecode(e.message) as Map<String, dynamic>;
      if (decoded.containsKey('message')) {
        message = decoded['message'] as String;
      } else if (decoded.containsKey('msg')) {
        message = decoded['msg'] as String;
      }
    } catch (_) {
      // Ignore JSON parse errors, fall back to the original message.
    }

    // Map common Supabase errors to user-friendly messages
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('email already in use') ||
        lowerMessage.contains('email already exists')) {
      return const AppAuthException('This email is already in use.');
    }

    if (lowerMessage.contains('invalid login credentials')) {
      return const AppAuthException('Invalid email or password.');
    }

    return AppAuthException(message);
  }

  @override
  String toString() => 'AppAuthException: $message';
}

/// Authentication service handling Supabase GoTrue operations
class AuthService {
  final SupabaseClient _supabase;

  AuthService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Current Supabase user
  User? get currentSupabaseUser => _supabase.auth.currentUser;

  /// Get current user ID or null
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// Register a new user with email and password
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    try {
      // 1. Create auth user in GoTrue with metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
          'role': role.toString().split('.').last, // Extract enum name
          'phone_number': phoneNumber,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AppAuthException('Failed to create account.');
      }

      // 2. Return user document (Trigger handles table insertion)
      return UserModel(
        uid: user.id,
        email: email,
        displayName: displayName,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      if (e is AuthException) {
        throw AppAuthException.fromSupabase(e);
      }
      throw AppAuthException('Registration error: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AppAuthException('Failed to sign in.');
      }

      // Update last login time
      // RLS should allow users to update their own last_login_at
      await _supabase
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);

      // Fetch user model
      final userModel = await getUserModel(user.id);
      if (userModel == null) {
        throw const AppAuthException('User profile not found.');
      }

      return userModel;
    } catch (e) {
      if (e is AuthException) {
        throw AppAuthException.fromSupabase(e);
      }
      throw AppAuthException('Sign in error: ${e.toString()}');
    }
  }

  /// Sign in with Google OAuth
  Future<UserModel?> signInWithGoogle({UserRole? role}) async {
    try {
      // 1. Initiate Google OAuth
      // On Web, this will redirect or open a popup depending on Supabase config
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.vacansee://login-callback',
        queryParams: {'prompt': 'select_account'},
      );

      if (!success) {
        throw const AppAuthException('Google sign-in failed to initiate.');
      }

      // NOTE: Account linking happens automatically in Supabase if "Link accounts with same email" is enabled.
      // If enabled, signing in with Google using an existing email will link to the original account.
      return null;
    } catch (e) {
      if (e is AuthException) {
        throw AppAuthException.fromSupabase(e);
      }
      throw AppAuthException('Google Sign-In error: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get user model from PostgreSQL
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (data == null) return null;
      return UserModel.fromJson(data);
    } catch (e) {
      throw AppAuthException('Failed to fetch user: ${e.toString()}');
    }
  }

  /// Update user profile in Supabase.
  /// When role is set to [UserRole.owner], [is_verified] is set to false.
  /// When role is [UserRole.student] or [UserRole.admin], [is_verified] is set to true.
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    UserRole? role,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (role != null) {
        updates['role'] = role.name;
        // Owners require admin verification; students and admins are auto-verified.
        updates['is_verified'] = role != UserRole.owner;
      }

      if (updates.isNotEmpty) {
        await _supabase.from('users').upsert({
          'id': uid,
          ...updates,
          'email': _supabase.auth.currentUser?.email, // Ensure email is present on upsert
        });
      }
    } catch (e) {
      throw AppAuthException('Failed to update profile: ${e.toString()}');
    }
  }

  /// Update user verification status (Admin only)
  Future<void> updateUserVerification({
    required String uid,
    required bool isVerified,
    UserRole? role,
  }) async {
    try {
      final updates = <String, dynamic>{
        'is_verified': isVerified,
      };
      if (role != null) updates['role'] = role.name;

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', uid)
          .select()
          .single();
    } catch (e) {
      throw AppAuthException('Failed to verify user: ${e.toString()}');
    }
  }

  /// Get pending owners for verification (Admin only)
  Future<List<UserModel>> getPendingOwners() async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('role', 'owner')
          .eq('is_verified', false)
          .order('created_at', ascending: false);
      
      return (data as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw AppAuthException('Failed to fetch pending owners: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? 'https://vacansee-xi.vercel.app' : null,
      );
    } catch (e) {
      if (e is AuthException) {
        throw AppAuthException.fromSupabase(e);
      }
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      if (e is AuthException) {
        throw AppAuthException.fromSupabase(e);
      }
      throw AppAuthException('Failed to update password: ${e.toString()}');
    }
  }
}
