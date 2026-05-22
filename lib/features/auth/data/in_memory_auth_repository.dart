import 'dart:async';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../../../app/core/app_error.dart';

class InMemoryAuthRepository implements AuthRepository {
  static const _demoEmail = 'demo@example.com';
  static const _demoPassword = 'password123';
  static const _demoUser = AuthUser(
    id: 'user-1',
    email: _demoEmail,
    name: 'Demo User',
  );

  AuthUser? _currentUser;
  final _authController = StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email == _demoEmail && password == _demoPassword) {
      _currentUser = _demoUser;
      _authController.add(_demoUser);
      return _demoUser;
    }
    throw const AppError(
      message: 'Invalid credentials',
      code: 'invalid_credentials',
    );
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = AuthUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
    );
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = _demoUser;
    _authController.add(_demoUser);
    return _demoUser;
  }

  @override
  Future<AuthUser> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = _demoUser;
    _authController.add(_demoUser);
    return _demoUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Stream<AuthUser?> onAuthStateChange() => _authController.stream;
}
