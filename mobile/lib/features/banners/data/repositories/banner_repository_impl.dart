import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/banner.dart';
import '../datasources/banner_remote_data_source.dart';
import 'dart:typed_data';

abstract class BannerRepository {
  Future<Either<Failure, BannerEntity>> createBanner({
    required String shopName,
    required String content,
    required String dimensions,
    required double latitude,
    required double longitude,
    String? address,
    String? customerId,
    String? leadId,
    Uint8List? photoBytes,
  });
  Future<Either<Failure, List<BannerEntity>>> getBanners({String? salesId, String? customerId, String? leadId});
}

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;

  BannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BannerEntity>> createBanner({
    required String shopName,
    required String content,
    required String dimensions,
    required double latitude,
    required double longitude,
    String? address,
    String? customerId,
    String? leadId,
    Uint8List? photoBytes,
  }) async {
    try {
      final banner = await remoteDataSource.createBanner(
        shopName: shopName,
        content: content,
        dimensions: dimensions,
        latitude: latitude,
        longitude: longitude,
        address: address,
        customerId: customerId,
        leadId: leadId,
        photoBytes: photoBytes,
      );
      return Right(banner);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners({String? salesId, String? customerId, String? leadId}) async {
    try {
      final banners = await remoteDataSource.getBanners(
        salesId: salesId,
        customerId: customerId,
        leadId: leadId,
      );
      return Right(banners);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
