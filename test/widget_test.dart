import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_career_tools/app/app.dart';
import 'package:ai_career_tools/features/auth/domain/entities/auth_session.dart';
import 'package:ai_career_tools/features/auth/domain/entities/sign_up_request.dart';
import 'package:ai_career_tools/features/auth/domain/entities/sign_up_result.dart';
import 'package:ai_career_tools/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_career_tools/features/auth/presentation/controllers/auth_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession?> observeAuthStateChanges() {
    return const Stream<AuthSession?>.empty();
  }

  @override
  Future<AuthSession?> restoreSession() async {
    return null;
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<SignUpResult> signUp(SignUpRequest request) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('shows splash screen while auth bootstrap is in progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const AICareerToolsApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Preparing your workspace...'), findsOneWidget);
    expect(find.text('AI Career Tools'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
