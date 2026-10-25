String? validateTitle(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Judul tidak boleh kosong';
  }
  return null;
}