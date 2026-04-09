import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/banner_model.dart';
import 'dart:io';

abstract class BannerRemoteDataSource {
  Future<BannerModel> createBanner({
    required String shopName,
    required String content,
    required String dimensions,
    required double latitude,
    required double longitude,
    String? address,
    String? customerId,
    String? leadId,
    File? photo,
  });
  Future<List<BannerModel>> getBanners({String? salesId, String? customerId, String? leadId});
}

class BannerRemoteDataSourceImpl implements BannerRemoteDataSource {
  final Dio dio;

  BannerRemoteDataSourceImpl(this.dio);

  @override
  Future<BannerModel> createBanner({
    required String shopName,
    required String content,
    required String dimensions,
    required double latitude,
    required double longitude,
    String? address,
    String? customerId,
    String? leadId,
    File? photo,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'shop_name': shopName,
        'content': content,
        'dimensions': dimensions,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
        if (customerId != null) 'customer_id': customerId,
        if (leadId != null) 'lead_id': leadId,
      };

      if (photo != null) {
        data['photo'] = await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);

      final response = await dio.post(
        ApiEndpoints.banners,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BannerModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Gagal menyimpan data spanduk');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }

  @override
  Future<List<BannerModel>> getBanners({String? salesId, String? customerId, String? leadId}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.banners,
        queryParameters: {
          if (salesId != null) 'sales_id': salesId,
          if (customerId != null) 'customer_id': customerId,
          if (leadId != null) 'lead_id': leadId,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Gagal mengambil data spanduk');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }
}
