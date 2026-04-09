import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/banner.dart';
import '../datasources/banner_remote_data_source.dart';
import 'dart:io';

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
    File? photo,
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
    File? photo,
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
        photo: photo,
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
