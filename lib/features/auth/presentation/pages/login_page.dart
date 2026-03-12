import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_status_note.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  String _registerLocation() {
    if (widget.redirectTo == null || widget.redirectTo == AppRoutes.home) {
      return AppRoutes.register;
    }

    return Uri(
      path: AppRoutes.register,
      queryParameters: {'from': widget.redirectTo},
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AppPlaceholderScaffold(
      eyebrow: 'Public route',
      title: 'Login',
      description: AppConstants.loginHeadline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              labelText: 'Email',
              hintText: 'jane@company.com',
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.compact),
            AppTextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              labelText: 'Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              validator: Validators.password,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.compact),
            AuthStatusNote(
              message:
                  widget.redirectTo == null ||
                      widget.redirectTo == AppRoutes.home
                  ? 'Sign in to continue into the protected workspace.'
                  : 'After login you will continue to ${widget.redirectTo}.',
            ),
            const SizedBox(height: AppSpacing.page),
            AppButton(
              label: 'Sign in',
              isLoading: authState.isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.compact),
            AppButton(
              label: 'Create a new account',
              variant: AppButtonVariant.secondary,
              onPressed: authState.isSubmitting
                  ? null
                  : () => context.go(_registerLocation()),
            ),
          ],
        ),
      ),
    );
  }
}
