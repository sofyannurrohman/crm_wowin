import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String role,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}
