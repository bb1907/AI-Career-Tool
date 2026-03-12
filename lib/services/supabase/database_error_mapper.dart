import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';

abstract final class DatabaseErrorMapper {
  static AppException map(Object error, {required String fallbackMessage}) {
    if (error is AppException) {
      return error;
    }

    if (error is PostgrestException) {
      final message = error.message.toLowerCase();

      if (message.contains('row-level security') ||
          error.code == '42501' ||
          error.code == 'PGRST301') {
        return const AppException(
          'You do not have permission to access this data.',
        );
      }

      if (message.contains('relation') && message.contains('does not exist')) {
        return const AppException(
          'Supabase tables are not ready yet. Run the SQL schema first.',
        );
      }

      return AppException(fallbackMessage);
    }

    if (error is AuthException) {
      return const AppException('Sign in again to continue.');
    }

    if (error is SocketException) {
      return const AppException(
        'Network connection failed. Check your internet and try again.',
      );
    }

    return AppException(fallbackMessage);
  }
}
