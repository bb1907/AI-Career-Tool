import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScaffold(
      eyebrow: 'Premium',
      title: 'Upgrade to Premium',
      description:
          'Unlock richer resume feedback, deeper company-specific cover letters and more advanced mock interview flows.',
      actions: [
        SizedBox(
          width: 220,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Back to Home'),
          ),
        ),
      ],
    );
  }
}
