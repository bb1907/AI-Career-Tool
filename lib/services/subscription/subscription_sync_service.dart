import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/constants.dart';
import 'subscription_status.dart';
import '../supabase/database_service.dart';

final subscriptionSyncServiceProvider = Provider<SubscriptionSyncService>(
  (ref) => SupabaseSubscriptionSyncService(ref.watch(databaseServiceProvider)),
);

abstract class SubscriptionSyncService {
  const SubscriptionSyncService();

  Future<void> syncStatus({
    required String userId,
    required SubscriptionStatus status,
  });
}

class SupabaseSubscriptionSyncService implements SubscriptionSyncService {
  const SupabaseSubscriptionSyncService(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<void> syncStatus({
    required String userId,
    required SubscriptionStatus status,
  }) async {
    try {
      await _databaseService.from(AppConstants.subscriptionsTable).upsert({
        'user_id': userId,
        'plan': status.plan.name,
        'is_premium': status.isPremium,
        'entitlement_id': status.entitlementId,
        'product_identifier': status.productIdentifier,
        'expires_at': status.expiresAt?.toIso8601String(),
        'management_url': status.managementUrl,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');
    } on PostgrestException catch (error) {
      final code = error.code ?? '';
      final message = error.message.toLowerCase();

      if (code == '42P01' ||
          code == '42703' ||
          message.contains('subscriptions') ||
          message.contains('schema cache')) {
        debugPrint('Subscription sync skipped: ${error.message}');
        return;
      }

      debugPrint('Subscription sync failed: ${error.message}');
    } catch (error) {
      debugPrint('Subscription sync failed: $error');
    }
  }
}
