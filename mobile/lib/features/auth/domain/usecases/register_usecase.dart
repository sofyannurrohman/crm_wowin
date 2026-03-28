import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    String companyName = '',
  }) async {
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Nama tidak boleh kosong'));
    }
    if (email.isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure('Email tidak valid'));
    }
    if (password.length < 8) {
      return const Left(
          ValidationFailure('Password minimal 8 karakter'));
    }

    return await repository.register(
      name: name.trim(),
      email: email.trim(),
      password: password,
      companyName: companyName.trim(),
    );
  }
}
