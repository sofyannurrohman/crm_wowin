// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Lead _$LeadFromJson(Map<String, dynamic> json) {
  return _Lead.fromJson(json);
}

/// @nodoc
mixin _$Lead {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String? get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_value')
  double? get estimatedValue => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'converted_at')
  DateTime? get convertedAt => throw _privateConstructorUsedError;

  /// Serializes this Lead to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadCopyWith<Lead> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadCopyWith<$Res> {
  factory $LeadCopyWith(Lead value, $Res Function(Lead) then) =
      _$LeadCopyWithImpl<$Res, Lead>;
  @useResult
  $Res call(
      {String id,
      String title,
      String name,
      String? company,
      String? email,
      String? phone,
      String source,
      String status,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'estimated_value') double? estimatedValue,
      String? notes,
      @JsonKey(name: 'converted_at') DateTime? convertedAt});
}

/// @nodoc
class _$LeadCopyWithImpl<$Res, $Val extends Lead>
    implements $LeadCopyWith<$Res> {
  _$LeadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? name = null,
    Object? company = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? source = null,
    Object? status = null,
    Object? customerId = freezed,
    Object? estimatedValue = freezed,
    Object? notes = freezed,
    Object? convertedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedValue: freezed == estimatedValue
          ? _value.estimatedValue
          : estimatedValue // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      convertedAt: freezed == convertedAt
          ? _value.convertedAt
          : convertedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeadImplCopyWith<$Res> implements $LeadCopyWith<$Res> {
  factory _$$LeadImplCopyWith(
          _$LeadImpl value, $Res Function(_$LeadImpl) then) =
      __$$LeadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String name,
      String? company,
      String? email,
      String? phone,
      String source,
      String status,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'estimated_value') double? estimatedValue,
      String? notes,
      @JsonKey(name: 'converted_at') DateTime? convertedAt});
}

/// @nodoc
class __$$LeadImplCopyWithImpl<$Res>
    extends _$LeadCopyWithImpl<$Res, _$LeadImpl>
    implements _$$LeadImplCopyWith<$Res> {
  __$$LeadImplCopyWithImpl(_$LeadImpl _value, $Res Function(_$LeadImpl) _then)
      : super(_value, _then);

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? name = null,
    Object? company = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? source = null,
    Object? status = null,
    Object? customerId = freezed,
    Object? estimatedValue = freezed,
    Object? notes = freezed,
    Object? convertedAt = freezed,
  }) {
    return _then(_$LeadImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      company: freezed == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedValue: freezed == estimatedValue
          ? _value.estimatedValue
          : estimatedValue // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      convertedAt: freezed == convertedAt
          ? _value.convertedAt
          : convertedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadImpl implements _Lead {
  const _$LeadImpl(
      {required this.id,
      required this.title,
      required this.name,
      this.company,
      this.email,
      this.phone,
      required this.source,
      required this.status,
      @JsonKey(name: 'customer_id') this.customerId,
      @JsonKey(name: 'estimated_value') this.estimatedValue,
      this.notes,
      @JsonKey(name: 'converted_at') this.convertedAt});

  factory _$LeadImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String name;
  @override
  final String? company;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String source;
  @override
  final String status;
  @override
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @override
  @JsonKey(name: 'estimated_value')
  final double? estimatedValue;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'converted_at')
  final DateTime? convertedAt;

  @override
  String toString() {
    return 'Lead(id: $id, title: $title, name: $name, company: $company, email: $email, phone: $phone, source: $source, status: $status, customerId: $customerId, estimatedValue: $estimatedValue, notes: $notes, convertedAt: $convertedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.estimatedValue, estimatedValue) ||
                other.estimatedValue == estimatedValue) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.convertedAt, convertedAt) ||
                other.convertedAt == convertedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, name, company, email,
      phone, source, status, customerId, estimatedValue, notes, convertedAt);

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadImplCopyWith<_$LeadImpl> get copyWith =>
      __$$LeadImplCopyWithImpl<_$LeadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadImplToJson(
      this,
    );
  }
}

abstract class _Lead implements Lead {
  const factory _Lead(
      {required final String id,
      required final String title,
      required final String name,
      final String? company,
      final String? email,
      final String? phone,
      required final String source,
      required final String status,
      @JsonKey(name: 'customer_id') final String? customerId,
      @JsonKey(name: 'estimated_value') final double? estimatedValue,
      final String? notes,
      @JsonKey(name: 'converted_at') final DateTime? convertedAt}) = _$LeadImpl;

  factory _Lead.fromJson(Map<String, dynamic> json) = _$LeadImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get name;
  @override
  String? get company;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String get source;
  @override
  String get status;
  @override
  @JsonKey(name: 'customer_id')
  String? get customerId;
  @override
  @JsonKey(name: 'estimated_value')
  double? get estimatedValue;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'converted_at')
  DateTime? get convertedAt;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadImplCopyWith<_$LeadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
