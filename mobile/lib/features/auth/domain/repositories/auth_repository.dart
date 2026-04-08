import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String companyName,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> checkAuthStatus();
  Future<Either<Failure, UserEntity>> getMe();
  Future<Either<Failure, UserEntity>> updateProfile({String? name, String? phone});
}
