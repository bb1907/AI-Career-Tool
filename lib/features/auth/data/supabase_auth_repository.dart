import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../app/core/app_error.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// [AuthRepository] backed by Supabase Auth.
///
/// Social sign-in (Google / Apple) is stubbed out until the native SDKs are
/// configured. The stubs throw so that [AuthNotifier] falls back to
/// [InMemoryAuthRepository].
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final sb.SupabaseClient _client;

  sb.GoTrueClient get _auth => _client.auth;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  AuthUser? _mapUser(sb.User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      name:
          user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String? ??
          user.email?.split('@').first ??
          '',
    );
  }

  // ---------------------------------------------------------------------------
  // Interface implementation
  // ---------------------------------------------------------------------------

  @override
  AuthUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  Stream<AuthUser?> onAuthStateChange() {
    return _auth.onAuthStateChange.map((data) => _mapUser(data.session?.user));
  }

  // ── Email / Password ──────────────────────────────────────────────────────

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = _mapUser(response.user);
      if (user == null) {
        throw const AppError(
          message: 'Sign-in returned no user',
          code: 'no_user',
        );
      }
      return user;
    } on sb.AuthException catch (e) {
      throw AppError(message: e.message, code: e.statusCode);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(message: 'Login failed: $e', code: 'login_error');
    }
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      final user = _mapUser(response.user);
      if (user == null) {
        throw const AppError(
          message: 'Sign-up returned no user',
          code: 'no_user',
        );
      }
      return user;
    } on sb.AuthException catch (e) {
      throw AppError(message: e.message, code: e.statusCode);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(message: 'Sign-up failed: $e', code: 'signup_error');
    }
  }

  // ── Google Sign-In (stub — SDK not configured yet) ─────────────────────────

  @override
  Future<AuthUser> signInWithGoogle() async {
    // TODO: Re-enable when google_sign_in package is added back and configured
    throw const AppError(
      message: 'Google Sign-In SDK not configured',
      code: 'not_configured',
    );
  }

  // ── Apple Sign-In (stub — SDK not configured yet) ──────────────────────────

  @override
  Future<AuthUser> signInWithApple() async {
    // TODO: Re-enable when sign_in_with_apple package is added back and configured
    throw const AppError(
      message: 'Apple Sign-In SDK not configured',
      code: 'not_configured',
    );
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on sb.AuthException catch (e) {
      throw AppError(message: e.message, code: e.statusCode);
    } catch (e) {
      throw AppError(message: 'Logout failed: $e', code: 'logout_error');
    }
  }

  // ── Account deletion ──────────────────────────────────────────────────────

  @override
  Future<void> deleteAccount() async {
    try {
      final userId = _auth.currentUser?.id;
      if (userId == null) return;
      // Delete user-owned rows; Supabase RLS + ON DELETE CASCADE handles
      // dependent tables (resumes, cover_letters, etc.).
      await _client.from('profiles').delete().eq('id', userId);
      // Sign out locally — full auth-user deletion requires an Edge Function
      // with the service-role key (see docs/implementation-artifacts/deferred-work.md).
      await _auth.signOut();
    } on sb.AuthException catch (e) {
      throw AppError(message: e.message, code: e.statusCode);
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(
        message: 'Account deletion failed: $e',
        code: 'delete_error',
      );
    }
  }
}
