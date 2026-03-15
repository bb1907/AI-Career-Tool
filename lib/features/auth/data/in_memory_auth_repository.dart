import '../domain/auth_user.dart';

class InMemoryAuthRepository {
  final List<AuthUser> _users = [];
  int _nextId = 0;

  AuthUser? login(String email, String password) {
    final normalised = email.toLowerCase();
    try {
      return _users.firstWhere(
        (u) => u.email == normalised && u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  String? register(String email, String password) {
    if (password.length < 6) return 'Password must be at least 6 characters';
    final normalised = email.toLowerCase();
    final exists = _users.any((u) => u.email == normalised);
    if (exists) return 'Email already registered';
    _users.add(AuthUser(
      id: (++_nextId).toString(),
      email: normalised,
      password: password,
    ));
    return null;
  }
}
