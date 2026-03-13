import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/constants.dart';
import '../../core/errors/app_exception.dart';
import '../supabase/database_error_mapper.dart';
import '../supabase/database_service.dart';
import 'premium_access_feature.dart';

final premiumAccessServiceProvider = Provider<PremiumAccessService>(
  (ref) => SupabasePremiumAccessService(ref.watch(databaseServiceProvider)),
);

class PremiumAccessSnapshot {
  const PremiumAccessSnapshot({
    required this.userId,
    required this.isPremium,
    required this.usedFreeGenerations,
    this.freeGenerationLimit = AppConstants.freeGenerationsLimit,
  });

  final String? userId;
  final bool isPremium;
  final int usedFreeGenerations;
  final int freeGenerationLimit;

  int get remainingFreeGenerations =>
      math.max(0, freeGenerationLimit - usedFreeGenerations);

  bool get hasReachedLimit =>
      !isPremium && usedFreeGenerations >= freeGenerationLimit;
}

class PremiumAccessDecision {
  const PremiumAccessDecision({
    required this.feature,
    required this.snapshot,
    required this.isAllowed,
    this.message,
    this.reservationId,
  });

  final PremiumAccessFeature feature;
  final PremiumAccessSnapshot snapshot;
  final bool isAllowed;
  final String? message;
  final String? reservationId;

  bool get requiresPaywall => !isAllowed;
}

abstract class PremiumAccessService {
  const PremiumAccessService();

  Future<PremiumAccessSnapshot> loadSnapshot({
    required String? userId,
    required bool isPremium,
  });

  Future<PremiumAccessDecision> evaluateAccess({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
  });

  Future<PremiumAccessSnapshot> recordSuccessfulUse({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
    String? reservationId,
  });

  Future<PremiumAccessSnapshot> releasePendingUse({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
    String? reservationId,
  });
}

class SupabasePremiumAccessService implements PremiumAccessService {
  SupabasePremiumAccessService(this._databaseService);

  final DatabaseService _databaseService;
  final math.Random _random = math.Random();

  @override
  Future<PremiumAccessSnapshot> loadSnapshot({
    required String? userId,
    required bool isPremium,
  }) async {
    final normalizedUserId = _normalizeUserId(userId);
    if (normalizedUserId == null || isPremium) {
      return PremiumAccessSnapshot(
        userId: normalizedUserId,
        isPremium: isPremium,
        usedFreeGenerations: 0,
      );
    }

    final usedFreeGenerations = await _loadUsageCount();

    return PremiumAccessSnapshot(
      userId: normalizedUserId,
      isPremium: isPremium,
      usedFreeGenerations: usedFreeGenerations,
    );
  }

  @override
  Future<PremiumAccessDecision> evaluateAccess({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
  }) async {
    final normalizedUserId = _normalizeUserId(userId);
    if (normalizedUserId == null || isPremium) {
      final snapshot = PremiumAccessSnapshot(
        userId: normalizedUserId,
        isPremium: isPremium,
        usedFreeGenerations: 0,
      );

      return PremiumAccessDecision(
        feature: feature,
        snapshot: snapshot,
        isAllowed: true,
      );
    }

    final reservationId = _buildReservationId(normalizedUserId, feature);
    final response = await _runUsageRpc(
      functionName: AppConstants.reserveUsageEventRpc,
      params: {
        'p_feature': feature.name,
        'p_reservation_key': reservationId,
        'p_limit': AppConstants.freeGenerationsLimit,
        'p_pending_ttl_minutes': AppConstants.usageReservationTtl.inMinutes,
      },
      fallbackMessage: 'Usage limits could not be checked right now.',
    );
    final snapshot = PremiumAccessSnapshot(
      userId: normalizedUserId,
      isPremium: false,
      usedFreeGenerations: _readInt(response, 'used_count'),
    );
    final isAllowed = _readBool(response, 'allowed');

    if (isAllowed) {
      return PremiumAccessDecision(
        feature: feature,
        snapshot: snapshot,
        isAllowed: true,
        reservationId: reservationId,
      );
    }

    return PremiumAccessDecision(
      feature: feature,
      snapshot: snapshot,
      isAllowed: false,
      message:
          'You have used all ${snapshot.freeGenerationLimit} free generations. Upgrade to continue with ${feature.label}.',
    );
  }

  @override
  Future<PremiumAccessSnapshot> recordSuccessfulUse({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
    String? reservationId,
  }) async {
    final normalizedUserId = _normalizeUserId(userId);
    if (normalizedUserId == null || isPremium) {
      return PremiumAccessSnapshot(
        userId: normalizedUserId,
        isPremium: isPremium,
        usedFreeGenerations: 0,
      );
    }

    final normalizedReservationId = _normalizeReservationId(reservationId);
    if (normalizedReservationId == null) {
      return loadSnapshot(userId: normalizedUserId, isPremium: false);
    }

    final response = await _runUsageRpc(
      functionName: AppConstants.finalizeUsageEventRpc,
      params: {
        'p_reservation_key': normalizedReservationId,
        'p_pending_ttl_minutes': AppConstants.usageReservationTtl.inMinutes,
      },
      fallbackMessage: 'Usage could not be saved right now.',
    );

    return PremiumAccessSnapshot(
      userId: normalizedUserId,
      isPremium: false,
      usedFreeGenerations: _readInt(response, 'used_count'),
    );
  }

  @override
  Future<PremiumAccessSnapshot> releasePendingUse({
    required String? userId,
    required bool isPremium,
    required PremiumAccessFeature feature,
    String? reservationId,
  }) async {
    final normalizedUserId = _normalizeUserId(userId);
    if (normalizedUserId == null || isPremium) {
      return PremiumAccessSnapshot(
        userId: normalizedUserId,
        isPremium: isPremium,
        usedFreeGenerations: 0,
      );
    }

    final normalizedReservationId = _normalizeReservationId(reservationId);
    if (normalizedReservationId == null) {
      return loadSnapshot(userId: normalizedUserId, isPremium: false);
    }

    final response = await _runUsageRpc(
      functionName: AppConstants.releaseUsageEventRpc,
      params: {
        'p_reservation_key': normalizedReservationId,
        'p_pending_ttl_minutes': AppConstants.usageReservationTtl.inMinutes,
      },
      fallbackMessage: 'Usage limits could not be restored right now.',
    );

    return PremiumAccessSnapshot(
      userId: normalizedUserId,
      isPremium: false,
      usedFreeGenerations: _readInt(response, 'used_count'),
    );
  }

  Future<int> _loadUsageCount() async {
    final response = await _runUsageRpc(
      functionName: AppConstants.getUsageSnapshotRpc,
      params: {
        'p_pending_ttl_minutes': AppConstants.usageReservationTtl.inMinutes,
      },
      fallbackMessage: 'Usage limits could not be loaded right now.',
    );

    return _readInt(response, 'used_count');
  }

  Future<Map<String, dynamic>> _runUsageRpc({
    required String functionName,
    required Map<String, dynamic> params,
    required String fallbackMessage,
  }) async {
    try {
      final response = await _databaseService
          .rpc<dynamic>(functionName, params: params)
          .single();
      return _coerceJsonMap(response);
    } on PostgrestException catch (error) {
      throw _mapUsageError(error, fallbackMessage: fallbackMessage);
    } catch (error) {
      throw _mapUsageError(error, fallbackMessage: fallbackMessage);
    }
  }

  AppException _mapUsageError(Object error, {required String fallbackMessage}) {
    if (error is AppException) {
      return error;
    }

    if (error is PostgrestException) {
      final message = error.message.toLowerCase();
      final isMissingUsageSetup =
          message.contains(AppConstants.usageEventsTable) ||
          message.contains(AppConstants.getUsageSnapshotRpc) ||
          message.contains(AppConstants.reserveUsageEventRpc) ||
          message.contains(AppConstants.finalizeUsageEventRpc) ||
          message.contains(AppConstants.releaseUsageEventRpc) ||
          error.code == '42883';

      if (isMissingUsageSetup) {
        return const AppException(
          'Usage limit setup is incomplete. Run the usage_events SQL schema first.',
        );
      }
    }

    return DatabaseErrorMapper.map(error, fallbackMessage: fallbackMessage);
  }

  Map<String, dynamic> _coerceJsonMap(Object? response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return response.map((key, value) => MapEntry(key.toString(), value));
    }

    throw const AppException('Usage limit response was invalid.');
  }

  int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final parsedValue = int.tryParse(value);
      if (parsedValue != null) {
        return parsedValue;
      }
    }

    throw const AppException('Usage limit response was invalid.');
  }

  bool _readBool(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value is bool) {
      return value;
    }

    throw const AppException('Usage limit response was invalid.');
  }

  String? _normalizeUserId(String? userId) {
    final normalizedUserId = userId?.trim() ?? '';
    return normalizedUserId.isEmpty ? null : normalizedUserId;
  }

  String? _normalizeReservationId(String? reservationId) {
    final normalizedReservationId = reservationId?.trim() ?? '';
    return normalizedReservationId.isEmpty ? null : normalizedReservationId;
  }

  String _buildReservationId(String userId, PremiumAccessFeature feature) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomValue = _random.nextInt(1 << 32).toRadixString(16);

    return '$userId:${feature.name}:$timestamp:$randomValue';
  }
}
