import 'package:flutter_test/flutter_test.dart';
import 'package:campu_notify/core/failures.dart';
import 'package:campu_notify/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;

    setUp(() {
      repository = const AuthRepositoryImpl();
    });

    test('login berhasil dengan email valid dan sandi >= 6 karakter', () async {
      final result = await repository.login(
        email: 'user@campus.ac.id',
        password: 'password123',
      );

      expect(result.failure, isNull);
      expect(result.session, isNotNull);
      expect(result.session!.access, 'mock-access-for-user@campus.ac.id');
      expect(result.session!.refresh, 'mock-refresh-for-user@campus.ac.id');
    });

    test('login gagal jika email tanpa @', () async {
      final result = await repository.login(
        email: 'invalidemail',
        password: 'password123',
      );

      expect(result.session, isNull);
      expect(result.failure, isA<AuthFailure>());
      expect(result.failure?.message, 'Email atau kata sandi tidak valid');
    });

    test('login gagal jika sandi kurang dari 6 karakter', () async {
      final result = await repository.login(
        email: 'user@campus.ac.id',
        password: '123',
      );

      expect(result.session, isNull);
      expect(result.failure, isA<AuthFailure>());
      expect(result.failure?.message, 'Email atau kata sandi tidak valid');
    });

    test('refresh mengembalikan token baru jika refreshToken tidak kosong', () async {
      final result = await repository.refresh('valid-refresh-token');

      expect(result.failure, isNull);
      expect(result.token, startsWith('mock-access-renewed-'));
    });

    test('refresh melempar failure jika refreshToken kosong', () async {
      final result = await repository.refresh('');

      expect(result.token, isNull);
      expect(result.failure, isA<AuthFailure>());
      expect(result.failure?.message, 'Refresh token hilang');
    });

    test('logout berhasil mengembalikan failure null', () async {
      final result = await repository.logout();

      expect(result.failure, isNull);
    });
  });
}
