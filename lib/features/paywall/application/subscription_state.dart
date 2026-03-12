import '../../../services/subscription/subscription_package.dart';
import '../../../services/subscription/subscription_status.dart';

class SubscriptionState {
  const SubscriptionState({
    this.userId,
    this.status = const SubscriptionStatus(),
    this.packages = const <SubscriptionPackage>[],
    this.isLoading = false,
    this.isRestoring = false,
    this.purchasingPackageId,
    this.errorMessage,
  });

  final String? userId;
  final SubscriptionStatus status;
  final List<SubscriptionPackage> packages;
  final bool isLoading;
  final bool isRestoring;
  final String? purchasingPackageId;
  final String? errorMessage;

  bool get isPremium => status.isPremium;
  bool get hasPackages => packages.isNotEmpty;
  bool get isBusy =>
      isLoading || isRestoring || (purchasingPackageId?.isNotEmpty ?? false);

  SubscriptionState copyWith({
    String? userId,
    SubscriptionStatus? status,
    List<SubscriptionPackage>? packages,
    bool? isLoading,
    bool? isRestoring,
    String? purchasingPackageId,
    String? errorMessage,
    bool clearError = false,
    bool clearPurchasingPackageId = false,
  }) {
    return SubscriptionState(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      isRestoring: isRestoring ?? this.isRestoring,
      purchasingPackageId: clearPurchasingPackageId
          ? null
          : purchasingPackageId ?? this.purchasingPackageId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
