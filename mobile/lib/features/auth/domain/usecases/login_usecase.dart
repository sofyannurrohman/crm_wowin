import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
      String email, String password) async {
    if (email.isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure('Email tidak valid'));
    }
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password tidak boleh kosong'));
    }

    return await repository.login(email, password);
  }
}
