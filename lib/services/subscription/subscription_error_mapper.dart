import 'package:flutter/services.dart';
import 'package:purchases_flutter/errors.dart';

import '../../core/errors/app_exception.dart';

abstract final class SubscriptionErrorMapper {
  static AppException map(Object error, {required String fallbackMessage}) {
    if (error is AppException) {
      return error;
    }

    if (error is PlatformException) {
      final code = PurchasesErrorHelper.getErrorCode(error);

      return switch (code) {
        PurchasesErrorCode.purchaseCancelledError => const AppException(
          'Purchase cancelled.',
          code: 'subscription_purchase_cancelled',
        ),
        PurchasesErrorCode.networkError ||
        PurchasesErrorCode.offlineConnectionError ||
        PurchasesErrorCode.productRequestTimeout => const AppException(
          'The App Store could not be reached. Check your connection and try again.',
          code: 'subscription_network',
          isRetryable: true,
        ),
        PurchasesErrorCode.storeProblemError ||
        PurchasesErrorCode.unexpectedBackendResponseError ||
        PurchasesErrorCode.unknownBackendError ||
        PurchasesErrorCode.apiEndpointBlocked => const AppException(
          'Subscription services are temporarily unavailable. Try again in a moment.',
          code: 'subscription_service_unavailable',
          isRetryable: true,
        ),
        PurchasesErrorCode.configurationError ||
        PurchasesErrorCode.invalidCredentialsError => const AppException(
          'Subscriptions are not configured correctly right now. Please try again later.',
          code: 'subscription_configuration',
        ),
        PurchasesErrorCode.productNotAvailableForPurchaseError =>
          const AppException(
            'This plan is not available for purchase right now.',
            code: 'subscription_plan_unavailable',
          ),
        PurchasesErrorCode.logOutWithAnonymousUserError => const AppException(
          'Subscription session is already cleared.',
          code: 'subscription_already_logged_out',
        ),
        _ => AppException(
          error.message?.trim().isNotEmpty == true
              ? error.message!.trim()
              : fallbackMessage,
          code: 'subscription_${code.name}',
        ),
      };
    }

    return AppException(fallbackMessage);
  }
}
