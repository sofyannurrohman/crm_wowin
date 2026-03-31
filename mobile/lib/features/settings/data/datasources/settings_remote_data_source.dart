import 'package:dio/dio.dart';
import '../../domain/entities/user_settings.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettings> getSettings();
  Future<void> updateSetting(String key, dynamic value);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio _dio;

  SettingsRemoteDataSourceImpl(this._dio);

  @override
  Future<UserSettings> getSettings() async {
    final response = await _dio.get('/settings');
    // Backend returns map of key -> value Directly in 'data'
    return UserSettings(data: response.data['data']);
  }

  @override
  Future<void> updateSetting(String key, dynamic value) async {
    await _dio.patch('/settings/$key', data: {'value': value});
  }
}
