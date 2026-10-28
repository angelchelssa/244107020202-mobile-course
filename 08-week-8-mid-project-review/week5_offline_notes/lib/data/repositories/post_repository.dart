import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../post.dart';

class PostRepository {
  PostRepository({Future<Database> Function()? openDb, Dio? dio})
    : _openDb = openDb ?? openNotesDb,
      _dio = dio ?? Dio();

  final Future<Database> Function() _openDb;
  final Dio _dio;

  Future<List<Post>> readCached() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map(
          (r) => Post.fromJson(
            jsonDecode(r['payload'] as String) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> saveCache(List<Post> posts) async {
    final db = await _openDb();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      for (final p in posts) {
        batch.insert('cached_posts', {
          'id': p.id,
          'payload': jsonEncode(p.toJson()),
          'cached_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Post>> fetchRemote() async {
    final res = await _dio.get<List<dynamic>>(
      'https://jsonplaceholder.typicode.com/posts',
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    return (res.data ?? [])
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
