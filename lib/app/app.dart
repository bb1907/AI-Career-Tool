import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/constants.dart';
import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/paywall/application/subscription_controller.dart';
import '../services/analytics/analytics_service.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class AICareerToolsApp extends ConsumerWidget {
  const AICareerToolsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.watch(subscriptionControllerProvider);
    ref.watch(analyticsBootstrapProvider);
    ref.listen(authControllerProvider, (previous, next) {
      final previousUserId = previous?.session?.userId;
      final nextUserId = next.session?.userId;

      if (previousUserId == nextUserId) {
        return;
      }

      unawaited(ref.read(analyticsServiceProvider).setUserId(nextUserId));
    });

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
