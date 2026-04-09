import 'package:dartz/dartz.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    try {
      final authModel = await remoteDataSource.login(email, password);

      // Save tokens securely immediately upon login
      await tokenStorage.saveTokens(
        access: authModel.accessToken,
        refresh: authModel.refreshToken,
      );

      return Right(authModel.user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan yang tidak terduga'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String companyName = '',
  }) async {
    try {
      await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        companyName: companyName,
      );
      // After registration, automatically log the user in
      final authModel = await remoteDataSource.login(email, password);
      await tokenStorage.saveTokens(
        access: authModel.accessToken,
        refresh: authModel.refreshToken,
      );
      return Right(authModel.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan yang tidak terduga'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getSalesmen() async {
    try {
      final salesmen = await remoteDataSource.getSalesmen();
      return Right(salesmen);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil data list salesman'));
    }
  }


  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await tokenStorage.clearTokens();
      return const Right(null);
    } catch (e) {
      return const Left(StorageFailure('Gagal menghapus sesi login'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> checkAuthStatus() async {
    try {
      final token = await tokenStorage.getAccessToken();
      if (token == null) {
        return const Right(null); // Unauthenticated
      }
      
      final profile = await remoteDataSource.getMe();
      return Right(profile);
    } catch (e) {
      // If profile fetch fails, assume session expired
      await tokenStorage.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getMe() async {
    try {
      final user = await remoteDataSource.getMe();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil data profil'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
      {String? name, String? phone}) async {
    try {
      final user = await remoteDataSource.updateProfile(
          name: name, phone: phone);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Gagal memperbarui profil'));
    }
  }
}
