// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return _Customer.fromJson(json);
}

/// @nodoc
mixin _$Customer {
  String get id => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_name')
  String? get companyName => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get industry => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'checkin_radius')
  int? get checkinRadius => throw _privateConstructorUsedError;

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerCopyWith<Customer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      _$CustomerCopyWithImpl<$Res, Customer>;
  @useResult
  $Res call(
      {String id,
      String? code,
      String name,
      @JsonKey(name: 'company_name') String? companyName,
      String? type,
      String? industry,
      String? email,
      String? phone,
      String? status,
      String? address,
      String? city,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'checkin_radius') int? checkinRadius});
}

/// @nodoc
class _$CustomerCopyWithImpl<$Res, $Val extends Customer>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = freezed,
    Object? name = null,
    Object? companyName = freezed,
    Object? type = freezed,
    Object? industry = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? status = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? checkinRadius = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      companyName: freezed == companyName
          ? _value.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      industry: freezed == industry
          ? _value.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      checkinRadius: freezed == checkinRadius
          ? _value.checkinRadius
          : checkinRadius // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomerImplCopyWith<$Res>
    implements $CustomerCopyWith<$Res> {
  factory _$$CustomerImplCopyWith(
          _$CustomerImpl value, $Res Function(_$CustomerImpl) then) =
      __$$CustomerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? code,
      String name,
      @JsonKey(name: 'company_name') String? companyName,
      String? type,
      String? industry,
      String? email,
      String? phone,
      String? status,
      String? address,
      String? city,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'checkin_radius') int? checkinRadius});
}

/// @nodoc
class __$$CustomerImplCopyWithImpl<$Res>
    extends _$CustomerCopyWithImpl<$Res, _$CustomerImpl>
    implements _$$CustomerImplCopyWith<$Res> {
  __$$CustomerImplCopyWithImpl(
      _$CustomerImpl _value, $Res Function(_$CustomerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = freezed,
    Object? name = null,
    Object? companyName = freezed,
    Object? type = freezed,
    Object? industry = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? status = freezed,
    Object? address = freezed,
    Object? city = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? checkinRadius = freezed,
  }) {
    return _then(_$CustomerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      companyName: freezed == companyName
          ? _value.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      industry: freezed == industry
          ? _value.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      checkinRadius: freezed == checkinRadius
          ? _value.checkinRadius
          : checkinRadius // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerImpl implements _Customer {
  const _$CustomerImpl(
      {required this.id,
      this.code,
      required this.name,
      @JsonKey(name: 'company_name') this.companyName,
      this.type,
      this.industry,
      this.email,
      this.phone,
      this.status,
      this.address,
      this.city,
      this.latitude,
      this.longitude,
      @JsonKey(name: 'checkin_radius') this.checkinRadius});

  factory _$CustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerImplFromJson(json);

  @override
  final String id;
  @override
  final String? code;
  @override
  final String name;
  @override
  @JsonKey(name: 'company_name')
  final String? companyName;
  @override
  final String? type;
  @override
  final String? industry;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? status;
  @override
  final String? address;
  @override
  final String? city;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'checkin_radius')
  final int? checkinRadius;

  @override
  String toString() {
    return 'Customer(id: $id, code: $code, name: $name, companyName: $companyName, type: $type, industry: $industry, email: $email, phone: $phone, status: $status, address: $address, city: $city, latitude: $latitude, longitude: $longitude, checkinRadius: $checkinRadius)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.industry, industry) ||
                other.industry == industry) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.checkinRadius, checkinRadius) ||
                other.checkinRadius == checkinRadius));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      name,
      companyName,
      type,
      industry,
      email,
      phone,
      status,
      address,
      city,
      latitude,
      longitude,
      checkinRadius);

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      __$$CustomerImplCopyWithImpl<_$CustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerImplToJson(
      this,
    );
  }
}

abstract class _Customer implements Customer {
  const factory _Customer(
          {required final String id,
          final String? code,
          required final String name,
          @JsonKey(name: 'company_name') final String? companyName,
          final String? type,
          final String? industry,
          final String? email,
          final String? phone,
          final String? status,
          final String? address,
          final String? city,
          final double? latitude,
          final double? longitude,
          @JsonKey(name: 'checkin_radius') final int? checkinRadius}) =
      _$CustomerImpl;

  factory _Customer.fromJson(Map<String, dynamic> json) =
      _$CustomerImpl.fromJson;

  @override
  String get id;
  @override
  String? get code;
  @override
  String get name;
  @override
  @JsonKey(name: 'company_name')
  String? get companyName;
  @override
  String? get type;
  @override
  String? get industry;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get status;
  @override
  String? get address;
  @override
  String? get city;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'checkin_radius')
  int? get checkinRadius;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
