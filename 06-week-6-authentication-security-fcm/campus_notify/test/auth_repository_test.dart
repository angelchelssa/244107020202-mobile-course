import 'package:flutter_test/flutter_test.dart';
import 'package:campu_notify/data/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepository repository;

    setUp(() {
      repository = AuthRepository();
    });

    test('login berhasil dengan email valid dan sandi >= 6 karakter', () async {
      final session = await repository.login(
        email: 'user@campus.ac.id',
        password: 'password123',
      );

      expect(session.access, 'mock-access-for-user@campus.ac.id');
      expect(session.refresh, 'mock-refresh-for-user@campus.ac.id');
    });

    test('login gagal jika email tanpa @', () async {
      expect(
        () => repository.login(email: 'invalidemail', password: 'password123'),
        throwsA(isA<Exception>()),
      );
    });

    test('login gagal jika sandi kurang dari 6 karakter', () async {
      expect(
        () => repository.login(email: 'user@campus.ac.id', password: '123'),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh mengembalikan token baru jika refreshToken tidak kosong', () async {
      final token = await repository.refresh('valid-refresh-token');
      expect(token, startsWith('mock-access-renewed-'));
    });

    test('refresh melempar exception jika refreshToken kosong', () async {
      expect(
        () => repository.refresh(''),
        throwsA(isA<Exception>()),
      );
    });
  });
}
