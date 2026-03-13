import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'analytics_events.dart';
import 'analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService();

  FirebaseAnalytics? _analytics;
  Future<void>? _initializationFuture;
  bool _isAvailable = false;
  bool _appOpenLogged = false;

  @override
  Future<void> initialize() {
    final initializationFuture = _initializationFuture;
    if (initializationFuture != null) {
      return initializationFuture;
    }

    final future = _initializeInternal();
    _initializationFuture = future;
    return future;
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    await initialize();
    final analytics = _analytics;
    if (!_isAvailable || analytics == null) {
      return;
    }

    try {
      await analytics.logEvent(
        name: name,
        parameters: _sanitizeParameters(parameters),
      );
    } catch (error) {
      debugPrint('Analytics logEvent failed for $name: $error');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    await initialize();
    final analytics = _analytics;
    if (!_isAvailable || analytics == null) {
      return;
    }

    try {
      await analytics.setUserId(id: _normalizeUserId(userId));
    } catch (error) {
      debugPrint('Analytics setUserId failed: $error');
    }
  }

  @override
  void dispose() {}

  Future<void> _initializeInternal() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);
      _analytics = analytics;
      _isAvailable = true;

      if (!_appOpenLogged) {
        _appOpenLogged = true;
        await analytics.logEvent(
          name: AnalyticsEvents.appOpen,
          parameters: _sanitizeParameters({
            'platform': defaultTargetPlatform.name,
            'build_mode': _buildMode,
          }),
        );
      }
    } catch (error) {
      _analytics = null;
      _isAvailable = false;
      debugPrint('Analytics initialization skipped: $error');
    }
  }

  String get _buildMode {
    if (kReleaseMode) {
      return 'release';
    }

    if (kProfileMode) {
      return 'profile';
    }

    return 'debug';
  }

  Map<String, Object> _sanitizeParameters(Map<String, Object?> parameters) {
    final sanitized = <String, Object>{};

    parameters.forEach((key, value) {
      if (value == null) {
        return;
      }

      if (value is String) {
        final normalizedValue = value.trim();
        if (normalizedValue.isEmpty) {
          return;
        }
        sanitized[key] = normalizedValue;
        return;
      }

      if (value is bool) {
        sanitized[key] = value ? 1 : 0;
        return;
      }

      if (value is num) {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  String? _normalizeUserId(String? userId) {
    final normalizedUserId = userId?.trim();
    if (normalizedUserId == null || normalizedUserId.isEmpty) {
      return null;
    }

    return normalizedUserId;
  }
}
