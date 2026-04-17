# Contract: AuthProvider/AuthService

## Interface: AuthProvider.completeOnboarding

This method handles the final step of the onboarding process, consolidating role selection and profile confirmation.

### Signature (Dart)
```dart
Future<bool> completeOnboarding({
  required UserRole role,
  required String displayName,
  required String phoneNumber,
})
```

### Logic flow
1. Set `_isLoading = true`.
2. Call `_authService.updateProfile` with all parameters.
3. Update local `_user` via `copyWith`.
4. Set `_status = AuthStatus.authenticated`.
5. Reset `_isLoading = false`.
6. `notifyListeners()`.

## Interface: AuthService.updateProfile

Supports partial updates to the user profile in PostgreSQL.

### Signature (Dart)
```dart
Future<void> updateProfile({
  required String uid,
  String? displayName,
  String? phoneNumber,
  UserRole? role,
})
```

### Logic flow
1. Construct a `Map<String, dynamic>` of non-null updates.
2. If `role` is provided, convert to `.name` string.
3. Perform `supabase.from('users').update(updates).eq('id', uid)`.
