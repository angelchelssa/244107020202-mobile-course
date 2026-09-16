import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:dio/dio.dart';

void main() {
  group('Post.fromJson', () {
    test('parsing normal, semua field lengkap', () {
      final json = {
        'userId': 1,
        'id': 1,
        'title': 'Judul contoh',
        'body': 'Isi contoh',
      };
      final post = Post.fromJson(json);

      expect(post.userId, 1);
      expect(post.id, 1);
      expect(post.title, 'Judul contoh');
      expect(post.body, 'Isi contoh');
    });

    test('parsing aman saat field hilang, tidak crash', () {
      final json = <String, dynamic>{
        'id': 5,
        // userId, title, body sengaja dihilangkan
      };
      final post = Post.fromJson(json);

      expect(post.id, 5);
      expect(post.userId, 0); // default aman
      expect(post.title, '');
      expect(post.body, '');
    });
  });

  group('friendlyErrorMessage', () {
    test('mapping DioExceptionType.connectionTimeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionTimeout,
      );
      final message = friendlyErrorMessage(error);

      expect(message, contains('timeout'));
    });

    test('mapping DioExceptionType.badResponse dengan status 404', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts/999'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/posts/999'),
          statusCode: 404,
        ),
      );
      final message = friendlyErrorMessage(error);

      expect(message, contains('tidak ditemukan'));
    });
  });
}