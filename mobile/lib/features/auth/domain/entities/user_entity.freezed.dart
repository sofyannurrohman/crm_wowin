// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserEntity {
  String get id;
  String get email;
  String get name;
  String get role;
  String? get phone;
  String? get status;
  @JsonKey(name: 'avatar_path')
  String? get avatarPath;
  @JsonKey(name: 'employee_code')
  String? get employeeCode;
  @JsonKey(name: 'sales_type')
  String? get salesType;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<UserEntity> get copyWith =>
      _$UserEntityCopyWithImpl<UserEntity>(this as UserEntity, _$identity);

  /// Serializes this UserEntity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserEntity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.avatarPath, avatarPath) ||
                other.avatarPath == avatarPath) &&
            (identical(other.employeeCode, employeeCode) ||
                other.employeeCode == employeeCode) &&
            (identical(other.salesType, salesType) ||
                other.salesType == salesType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, name, role, phone,
      status, avatarPath, employeeCode, salesType);

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name, role: $role, phone: $phone, status: $status, avatarPath: $avatarPath, employeeCode: $employeeCode, salesType: $salesType)';
  }
}

/// @nodoc
abstract mixin class $UserEntityCopyWith<$Res> {
  factory $UserEntityCopyWith(
          UserEntity value, $Res Function(UserEntity) _then) =
      _$UserEntityCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      String role,
      String? phone,
      String? status,
      @JsonKey(name: 'avatar_path') String? avatarPath,
      @JsonKey(name: 'employee_code') String? employeeCode,
      @JsonKey(name: 'sales_type') String? salesType});
}

/// @nodoc
class _$UserEntityCopyWithImpl<$Res> implements $UserEntityCopyWith<$Res> {
  _$UserEntityCopyWithImpl(this._self, this._then);

  final UserEntity _self;
  final $Res Function(UserEntity) _then;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? role = null,
    Object? phone = freezed,
    Object? status = freezed,
    Object? avatarPath = freezed,
    Object? employeeCode = freezed,
    Object? salesType = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarPath: freezed == avatarPath
          ? _self.avatarPath
          : avatarPath // ignore: cast_nullable_to_non_nullable
              as String?,
      employeeCode: freezed == employeeCode
          ? _self.employeeCode
          : employeeCode // ignore: cast_nullable_to_non_nullable
              as String?,
      salesType: freezed == salesType
          ? _self.salesType
          : salesType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserEntity].
extension UserEntityPatterns on UserEntity {
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
    TResult Function(_UserEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserEntity() when $default != null:
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
    TResult Function(_UserEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserEntity():
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
    TResult? Function(_UserEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserEntity() when $default != null:
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
            String email,
            String name,
            String role,
            String? phone,
            String? status,
            @JsonKey(name: 'avatar_path') String? avatarPath,
            @JsonKey(name: 'employee_code') String? employeeCode,
            @JsonKey(name: 'sales_type') String? salesType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserEntity() when $default != null:
        return $default(
            _that.id,
            _that.email,
            _that.name,
            _that.role,
            _that.phone,
            _that.status,
            _that.avatarPath,
            _that.employeeCode,
            _that.salesType);
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
            String email,
            String name,
            String role,
            String? phone,
            String? status,
            @JsonKey(name: 'avatar_path') String? avatarPath,
            @JsonKey(name: 'employee_code') String? employeeCode,
            @JsonKey(name: 'sales_type') String? salesType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserEntity():
        return $default(
            _that.id,
            _that.email,
            _that.name,
            _that.role,
            _that.phone,
            _that.status,
            _that.avatarPath,
            _that.employeeCode,
            _that.salesType);
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
            String email,
            String name,
            String role,
            String? phone,
            String? status,
            @JsonKey(name: 'avatar_path') String? avatarPath,
            @JsonKey(name: 'employee_code') String? employeeCode,
            @JsonKey(name: 'sales_type') String? salesType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserEntity() when $default != null:
        return $default(
            _that.id,
            _that.email,
            _that.name,
            _that.role,
            _that.phone,
            _that.status,
            _that.avatarPath,
            _that.employeeCode,
            _that.salesType);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserEntity implements UserEntity {
  const _UserEntity(
      {required this.id,
      required this.email,
      required this.name,
      required this.role,
      this.phone,
      this.status,
      @JsonKey(name: 'avatar_path') this.avatarPath,
      @JsonKey(name: 'employee_code') this.employeeCode,
      @JsonKey(name: 'sales_type') this.salesType});
  factory _UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;
  @override
  final String role;
  @override
  final String? phone;
  @override
  final String? status;
  @override
  @JsonKey(name: 'avatar_path')
  final String? avatarPath;
  @override
  @JsonKey(name: 'employee_code')
  final String? employeeCode;
  @override
  @JsonKey(name: 'sales_type')
  final String? salesType;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserEntityCopyWith<_UserEntity> get copyWith =>
      __$UserEntityCopyWithImpl<_UserEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserEntityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserEntity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.avatarPath, avatarPath) ||
                other.avatarPath == avatarPath) &&
            (identical(other.employeeCode, employeeCode) ||
                other.employeeCode == employeeCode) &&
            (identical(other.salesType, salesType) ||
                other.salesType == salesType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, name, role, phone,
      status, avatarPath, employeeCode, salesType);

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name, role: $role, phone: $phone, status: $status, avatarPath: $avatarPath, employeeCode: $employeeCode, salesType: $salesType)';
  }
}

/// @nodoc
abstract mixin class _$UserEntityCopyWith<$Res>
    implements $UserEntityCopyWith<$Res> {
  factory _$UserEntityCopyWith(
          _UserEntity value, $Res Function(_UserEntity) _then) =
      __$UserEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String name,
      String role,
      String? phone,
      String? status,
      @JsonKey(name: 'avatar_path') String? avatarPath,
      @JsonKey(name: 'employee_code') String? employeeCode,
      @JsonKey(name: 'sales_type') String? salesType});
}

/// @nodoc
class __$UserEntityCopyWithImpl<$Res> implements _$UserEntityCopyWith<$Res> {
  __$UserEntityCopyWithImpl(this._self, this._then);

  final _UserEntity _self;
  final $Res Function(_UserEntity) _then;

  /// Create a copy of UserEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? role = null,
    Object? phone = freezed,
    Object? status = freezed,
    Object? avatarPath = freezed,
    Object? employeeCode = freezed,
    Object? salesType = freezed,
  }) {
    return _then(_UserEntity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarPath: freezed == avatarPath
          ? _self.avatarPath
          : avatarPath // ignore: cast_nullable_to_non_nullable
              as String?,
      employeeCode: freezed == employeeCode
          ? _self.employeeCode
          : employeeCode // ignore: cast_nullable_to_non_nullable
              as String?,
      salesType: freezed == salesType
          ? _self.salesType
          : salesType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
