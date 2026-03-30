// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Customer {
  String get id;
  String? get code;
  String get name;
  @JsonKey(name: 'company_name')
  String? get companyName;
  String? get type;
  String? get industry;
  String? get email;
  String? get phone;
  String? get status;
  String? get address;
  String? get city;
  double? get latitude;
  double? get longitude;
  @JsonKey(name: 'checkin_radius')
  int? get checkinRadius;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomerCopyWith<Customer> get copyWith =>
      _$CustomerCopyWithImpl<Customer>(this as Customer, _$identity);

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Customer &&
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

  @override
  String toString() {
    return 'Customer(id: $id, code: $code, name: $name, companyName: $companyName, type: $type, industry: $industry, email: $email, phone: $phone, status: $status, address: $address, city: $city, latitude: $latitude, longitude: $longitude, checkinRadius: $checkinRadius)';
  }
}

/// @nodoc
abstract mixin class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) _then) =
      _$CustomerCopyWithImpl;
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
class _$CustomerCopyWithImpl<$Res> implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._self, this._then);

  final Customer _self;
  final $Res Function(Customer) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      companyName: freezed == companyName
          ? _self.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      industry: freezed == industry
          ? _self.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      checkinRadius: freezed == checkinRadius
          ? _self.checkinRadius
          : checkinRadius // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Customer].
extension CustomerPatterns on Customer {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Customer value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Customer() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Customer value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Customer():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Customer value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Customer() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
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
            @JsonKey(name: 'checkin_radius') int? checkinRadius)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Customer() when $default != null:
        return $default(
            _that.id,
            _that.code,
            _that.name,
            _that.companyName,
            _that.type,
            _that.industry,
            _that.email,
            _that.phone,
            _that.status,
            _that.address,
            _that.city,
            _that.latitude,
            _that.longitude,
            _that.checkinRadius);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
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
            @JsonKey(name: 'checkin_radius') int? checkinRadius)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Customer():
        return $default(
            _that.id,
            _that.code,
            _that.name,
            _that.companyName,
            _that.type,
            _that.industry,
            _that.email,
            _that.phone,
            _that.status,
            _that.address,
            _that.city,
            _that.latitude,
            _that.longitude,
            _that.checkinRadius);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
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
            @JsonKey(name: 'checkin_radius') int? checkinRadius)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Customer() when $default != null:
        return $default(
            _that.id,
            _that.code,
            _that.name,
            _that.companyName,
            _that.type,
            _that.industry,
            _that.email,
            _that.phone,
            _that.status,
            _that.address,
            _that.city,
            _that.latitude,
            _that.longitude,
            _that.checkinRadius);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Customer implements Customer {
  const _Customer(
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
  factory _Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

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

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CustomerCopyWith<_Customer> get copyWith =>
      __$CustomerCopyWithImpl<_Customer>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomerToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Customer &&
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

  @override
  String toString() {
    return 'Customer(id: $id, code: $code, name: $name, companyName: $companyName, type: $type, industry: $industry, email: $email, phone: $phone, status: $status, address: $address, city: $city, latitude: $latitude, longitude: $longitude, checkinRadius: $checkinRadius)';
  }
}

/// @nodoc
abstract mixin class _$CustomerCopyWith<$Res>
    implements $CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(_Customer value, $Res Function(_Customer) _then) =
      __$CustomerCopyWithImpl;
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
class __$CustomerCopyWithImpl<$Res> implements _$CustomerCopyWith<$Res> {
  __$CustomerCopyWithImpl(this._self, this._then);

  final _Customer _self;
  final $Res Function(_Customer) _then;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_Customer(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      companyName: freezed == companyName
          ? _self.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      industry: freezed == industry
          ? _self.industry
          : industry // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      checkinRadius: freezed == checkinRadius
          ? _self.checkinRadius
          : checkinRadius // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
