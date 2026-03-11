import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';

abstract final class AuthErrorMessageMapper {
  static AppException map(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is AuthWeakPasswordException) {
      final reason = error.reasons.isEmpty ? null : error.reasons.first;
      return AppException(
        reason == null
            ? 'Password is too weak. Use at least 8 characters.'
            : 'Password is too weak: $reason',
      );
    }

    if (error is AuthException) {
      final code = error.code?.toLowerCase();
      final message = error.message.toLowerCase();

      if (code == 'invalid_credentials' ||
          message.contains('invalid login credentials')) {
        return const AppException('Email or password is incorrect.');
      }

      if (code == 'email_not_confirmed' ||
          message.contains('email not confirmed')) {
        return const AppException(
          'Confirm your email address before signing in.',
        );
      }

      if (message.contains('user already registered')) {
        return const AppException(
          'An account already exists for this email. Try signing in instead.',
        );
      }

      if (message.contains('signup is disabled')) {
        return const AppException(
          'Email sign up is currently disabled in Supabase.',
        );
      }

      return AppException(error.message);
    }

    if (error is PostgrestException) {
      return const AppException(
        'Your account was created, but the profile record could not be prepared. Run the SQL schema and try again.',
      );
    }

    return const AppException('Something went wrong. Please try again.');
  }
}
