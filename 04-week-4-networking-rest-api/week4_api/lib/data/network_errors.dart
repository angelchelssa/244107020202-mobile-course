import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa jaringan Anda dan coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data tidak ditemukan.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'Server sedang bermasalah. Coba lagi nanti.';
        }
        return 'Terjadi kesalahan pada permintaan (kode $statusCode).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat keamanan tidak valid.';
      default:
        return 'Terjadi kesalahan yang tidak diketahui. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan. Coba lagi.';
}