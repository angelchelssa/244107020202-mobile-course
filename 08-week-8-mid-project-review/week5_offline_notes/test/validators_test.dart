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
}
