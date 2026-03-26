import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class AuthModel with _$AuthModel {
  const factory AuthModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    required UserEntity user,
  }) = _AuthModel;

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);
}
