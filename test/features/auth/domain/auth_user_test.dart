import 'package:flutter_test/flutter_test.dart';
import 'package:ai_career_tools/features/auth/domain/auth_user.dart';

void main() {
  group('AuthUser', () {
    test('creates with required fields', () {
      const user = AuthUser(
        id: 'user-123',
        email: 'jane@example.com',
        name: 'Jane Doe',
      );

      expect(user.id, 'user-123');
      expect(user.email, 'jane@example.com');
      expect(user.name, 'Jane Doe');
    });

    test('two instances with same values are independent', () {
      const user1 = AuthUser(id: 'u1', email: 'a@b.com', name: 'Alice');
      const user2 = AuthUser(id: 'u1', email: 'a@b.com', name: 'Alice');

      expect(user1.id, user2.id);
      expect(user1.email, user2.email);
      expect(user1.name, user2.name);
    });

    test('stores different user data correctly', () {
      const user1 = AuthUser(
        id: 'u1',
        email: 'alice@example.com',
        name: 'Alice',
      );
      const user2 = AuthUser(id: 'u2', email: 'bob@example.com', name: 'Bob');

      expect(user1.id, isNot(user2.id));
      expect(user1.email, isNot(user2.email));
      expect(user1.name, isNot(user2.name));
    });

    test('handles empty strings', () {
      const user = AuthUser(id: '', email: '', name: '');

      expect(user.id, '');
      expect(user.email, '');
      expect(user.name, '');
    });

    test('handles special characters in fields', () {
      const user = AuthUser(
        id: 'uuid-v4-abc-123',
        email: 'user+tag@sub.domain.com',
        name: "O'Brien-Smith",
      );

      expect(user.id, 'uuid-v4-abc-123');
      expect(user.email, 'user+tag@sub.domain.com');
      expect(user.name, "O'Brien-Smith");
    });
  });
}
