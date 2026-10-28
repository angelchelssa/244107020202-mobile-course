String? validateTitle(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Judul tidak boleh kosong';
  }
  if (value.trim().length > 200) {
    return 'Judul terlalu panjang (maks. 200 karakter)';
  }
  return null;
}

/// Mengembalikan pesan error jika [value] (setelah trim) sudah ada di
/// [existingTitles] (perbandingan case-insensitive), atau null jika tidak ada
/// duplikat. Dipanggil setelah [validateTitle] lulus.
String? validateTitleDuplicate(String? value, List<String> existingTitles) {
  if (value == null) return null;
  final trimmed = value.trim().toLowerCase();
  final isDuplicate = existingTitles.any(
    (t) => t.trim().toLowerCase() == trimmed,
  );
  return isDuplicate ? 'Judul catatan sudah ada' : null;
}
