import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/sign_up_request.dart';
import '../providers/auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _targetRoleController = TextEditingController();
  final _yearsController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmittingLocally = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _targetRoleController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmittingLocally || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmittingLocally = true;
    });

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .signUp(
            SignUpRequest(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              targetRole: _targetRoleController.text.trim(),
              yearsOfExperience: int.parse(_yearsController.text.trim()),
            ),
          );

      if (!mounted) {
        return;
      }

      AppFeedback.showSuccess(context, result.message);

      if (result.requiresEmailConfirmation) {
        context.go(_loginLocation());
      }
    } on AppException catch (error) {
      if (mounted) {
        AppFeedback.showError(context, error.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingLocally = false;
        });
      }
    }
  }

  String _loginLocation() {
    if (widget.redirectTo == null || widget.redirectTo == AppRoutes.home) {
      return AppRoutes.login;
    }

    return Uri(
      path: AppRoutes.login,
      queryParameters: {'from': widget.redirectTo},
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.isSubmitting || _isSubmittingLocally;

    return AppPlaceholderScaffold(
      eyebrow: 'Public route',
      title: 'Create account',
      description: AppConstants.registerHeadline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              labelText: 'Full name',
              hintText: 'Jane Doe',
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Full name'),
            ),
            const SizedBox(height: AppSpacing.compact),
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
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              labelText: 'Password',
              hintText: 'At least 8 characters',
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
            ),
            const SizedBox(height: AppSpacing.compact),
            AppTextField(
              controller: _targetRoleController,
              textInputAction: TextInputAction.next,
              labelText: 'Target role',
              hintText: 'Senior Product Designer',
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Target role'),
            ),
            const SizedBox(height: AppSpacing.compact),
            AppTextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              labelText: 'Years of experience',
              hintText: '5',
              validator: Validators.yearsOfExperience,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.page),
            AppButton(
              label: 'Create account',
              isLoading: isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.compact),
            AppButton(
              label: 'I already have an account',
              variant: AppButtonVariant.secondary,
              onPressed: isSubmitting
                  ? null
                  : () => context.go(_loginLocation()),
            ),
          ],
        ),
      ),
    );
  }
}
