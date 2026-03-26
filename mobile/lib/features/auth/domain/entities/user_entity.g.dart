// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserEntityImpl _$$UserEntityImplFromJson(Map<String, dynamic> json) =>
    _$UserEntityImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );

Map<String, dynamic> _$$UserEntityImplToJson(_$UserEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };
