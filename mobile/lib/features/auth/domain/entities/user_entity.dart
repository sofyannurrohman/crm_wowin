import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String name,
    required String role,
    String? phone,
    String? status,
    @JsonKey(name: 'avatar_path') String? avatarPath,
    @JsonKey(name: 'employee_code') String? employeeCode,
    @JsonKey(name: 'sales_type') String? salesType,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}
