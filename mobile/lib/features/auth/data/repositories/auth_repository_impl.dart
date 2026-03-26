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
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
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
      // Note: We'd typically decrypt the JWT manually or call a '/me' API.
      // Assuming token exists is sufficient for immediate UI gating. Interceptor handles truth.
      // But we will return a minimal dummy entity since we lack `/me` endpoint payload right now.
      return const Right(UserEntity(
        id: 'cached', 
        email: 'user@wowin.id', 
        role: 'sales', 
        firstName: 'Sales', 
        lastName: 'Wowin',
      )); 
    } catch (e) {
      return const Left(StorageFailure('Gagal mengecek status sesi'));
    }
  }
}
