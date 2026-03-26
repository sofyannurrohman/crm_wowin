class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Terjadi kesalahan pada server']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Gagal menyimpan atau mengambil data lokal']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Gagal memverifikasi akses autentikasi']);
}

class LocationException implements Exception {
  final String message;
  const LocationException([this.message = 'Gagal mendapatkan akses lokasi perangkat']);
}
