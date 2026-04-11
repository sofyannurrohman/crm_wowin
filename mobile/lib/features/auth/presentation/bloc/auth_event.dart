import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String salesType;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.salesType,
  });

  @override
  List<Object> get props => [name, email, password, salesType];
}

class LogoutRequested extends AuthEvent {}

class FetchProfile extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? phone;

  const UpdateProfileRequested({this.name, this.phone});

  @override
  List<Object?> get props => [name, phone];
}

class FetchSalesmen extends AuthEvent {}
