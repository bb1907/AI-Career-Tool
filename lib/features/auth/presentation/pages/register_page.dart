import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/app_spacing.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/app_placeholder_scaffold.dart';
import '../../domain/entities/sign_up_request.dart';
import '../controllers/auth_controller.dart';

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);

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

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.message)));

      if (result.requiresEmailConfirmation) {
        context.go(_loginLocation());
      }
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

    return AppPlaceholderScaffold(
      eyebrow: 'Public route',
      title: 'Create account',
      description: AppConfig.registerHeadline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full name',
                hintText: 'Jane Doe',
              ),
              validator: (value) =>
                  InputValidators.requiredField(value, fieldName: 'Full name'),
            ),
            const SizedBox(height: AppSpacing.compact),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'jane@company.com',
              ),
              validator: InputValidators.email,
            ),
            const SizedBox(height: AppSpacing.compact),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
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
              ),
              validator: InputValidators.password,
            ),
            const SizedBox(height: AppSpacing.compact),
            TextFormField(
              controller: _targetRoleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Target role',
                hintText: 'Senior Product Designer',
              ),
              validator: (value) => InputValidators.requiredField(
                value,
                fieldName: 'Target role',
              ),
            ),
            const SizedBox(height: AppSpacing.compact),
            TextFormField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Years of experience',
                hintText: '5',
              ),
              validator: InputValidators.yearsOfExperience,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.page),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authState.isSubmitting ? null : _submit,
                child: authState.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create account'),
              ),
            ),
            const SizedBox(height: AppSpacing.compact),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: authState.isSubmitting
                    ? null
                    : () => context.go(_loginLocation()),
                child: const Text('I already have an account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
