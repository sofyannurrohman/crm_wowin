import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String companyName,
  });
  Future<List<UserEntity>> getSalesmen();
  Future<UserEntity> getMe();
  Future<UserEntity> updateProfile({String? name, String? phone});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = Map<String, dynamic>.from(response.data['data']);
        if (data['user'] != null) {
          data['user'] = _mapToUser(data['user'] as Map<String, dynamic>);
        }
        return AuthModel.fromJson(data);
      } else {
        throw ServerException(
            response.data['message'] ?? 'Unknown authentication error');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Email atau password salah');
      }
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String companyName = '',
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (companyName.isNotEmpty) 'company_name': companyName,
        },
      );

      if (response.statusCode != 201) {
        throw ServerException(
            response.data['message'] ?? 'Registrasi gagal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ServerException('Email sudah terdaftar');
      }
      if (e.response?.statusCode == 400) {
        final msg = e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Data registrasi tidak valid';
        throw ServerException(msg.toString());
      }
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<List<UserEntity>> getSalesmen() async {
    try {
      final response = await dio.get('/users', queryParameters: {'role': 'salesman'});
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List data = response.data['data'];
        return data.map((e) => UserEntity.fromJson(e)).toList();
      } else {
        throw ServerException('Gagal mengambil data salesman');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<UserEntity> getMe() async {
    try {
      final response = await dio.get(ApiEndpoints.getMe);
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = _mapToUser(response.data['data'] as Map<String, dynamic>);
        return UserEntity.fromJson(data);
      } else {
        throw ServerException('Gagal mengambil data profil');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<UserEntity> updateProfile({String? name, String? phone}) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.updateProfile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = _mapToUser(response.data['data'] as Map<String, dynamic>);
        return UserEntity.fromJson(data);
      } else {
        throw ServerException(
            response.data['message'] ?? 'Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  Map<String, dynamic> _mapToUser(Map<String, dynamic> json) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);
    if (normalized['id'] != null) {
      normalized['id'] = normalized['id'].toString();
    }
    return normalized;
  }
}
