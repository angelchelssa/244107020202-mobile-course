import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/utils/validators.dart';

void main() {
  test('judul kosong ditolak', () {
    expect(validateTitle(''), 'Judul tidak boleh kosong');
    expect(validateTitle('   '), 'Judul tidak boleh kosong');
    expect(validateTitle(null), 'Judul tidak boleh kosong');
  });

  test('judul terisi diterima', () {
    expect(validateTitle('Catatan kuliah'), isNull);
  });

  test('judul hanya spasi ditolak', () {
    expect(validateTitle(' '), 'Judul tidak boleh kosong');
    expect(validateTitle('\t'), 'Judul tidak boleh kosong');
    expect(validateTitle('   \n  '), 'Judul tidak boleh kosong');
  });

  test('judul <= 200 karakter diterima, > 200 karakter ditolak', () {
    final pas = 'a' * 200;
    final terlalu = 'a' * 201;
    expect(validateTitle(pas), isNull);
    expect(
      validateTitle(terlalu),
      'Judul terlalu panjang (maks. 200 karakter)',
    );
  });

  test('duplikat case-insensitive ditolak', () {
    final existing = ['Catatan Kuliah', 'Tugas PemMob'];

    expect(
      validateTitleDuplicate('Catatan Kuliah', existing),
      'Judul catatan sudah ada',
    );
    expect(
      validateTitleDuplicate('catatan kuliah', existing),
      'Judul catatan sudah ada',
    );
    expect(
      validateTitleDuplicate('CATATAN KULIAH', existing),
      'Judul catatan sudah ada',
    );
    expect(
      validateTitleDuplicate('  catatan kuliah  ', existing),
      'Judul catatan sudah ada',
    );
    expect(validateTitleDuplicate('Catatan Baru', existing), isNull);
    expect(validateTitleDuplicate(null, existing), isNull);
  });
}
