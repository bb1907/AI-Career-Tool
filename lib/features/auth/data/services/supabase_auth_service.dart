import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/sign_up_request.dart';
import '../../domain/entities/sign_up_result.dart';
import 'auth_error_message_mapper.dart';

class SupabaseAuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  Future<AuthSession?> restoreSession() async {
    final user = _client.auth.currentSession?.user;
    return user == null ? null : _mapUser(user);
  }

  Stream<AuthSession?> observeAuthStateChanges() {
    return _client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user == null ? null : _mapUser(user);
    });
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;

      if (user == null) {
        throw const AppException('Sign in did not return a user session.');
      }

      return _mapUser(user);
    } catch (error) {
      throw AuthErrorMessageMapper.map(error);
    }
  }

  Future<SignUpResult> signUp(SignUpRequest request) async {
    try {
      final response = await _client.auth.signUp(
        email: request.email.trim(),
        password: request.password,
        data: {
          'full_name': request.fullName.trim(),
          'target_role': request.targetRole.trim(),
          'years_of_experience': request.yearsOfExperience,
        },
      );
      final user = response.user;

      if (user == null) {
        throw const AppException('Account creation did not complete.');
      }

      if (response.session == null) {
        return const SignUpResult(
          message:
              'Account created. Check your email to confirm the account, then sign in.',
          requiresEmailConfirmation: true,
        );
      }

      return SignUpResult(
        message: 'Account created successfully.',
        requiresEmailConfirmation: false,
        session: _mapUser(user),
      );
    } catch (error) {
      throw AuthErrorMessageMapper.map(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw AuthErrorMessageMapper.map(error);
    }
  }

  AuthSession _mapUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};

    return AuthSession(
      userId: user.id,
      email: user.email ?? '',
      fullName: _readString(metadata['full_name']),
      targetRole: _readString(metadata['target_role']),
      yearsOfExperience: _readInt(metadata['years_of_experience']),
    );
  }

  String? _readString(Object? value) {
    final normalizedValue = value?.toString().trim() ?? '';
    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }
}
