// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Deal _$DealFromJson(Map<String, dynamic> json) {
  return _Deal.fromJson(json);
}

/// @nodoc
mixin _$Deal {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_id')
  String get customerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'contact_id')
  String? get contactId => throw _privateConstructorUsedError;
  String get stage => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;
  int? get probability => throw _privateConstructorUsedError;
  @JsonKey(name: 'expected_close')
  DateTime? get expectedClose => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this Deal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DealCopyWith<Deal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DealCopyWith<$Res> {
  factory $DealCopyWith(Deal value, $Res Function(Deal) then) =
      _$DealCopyWithImpl<$Res, Deal>;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'customer_id') String customerId,
      @JsonKey(name: 'contact_id') String? contactId,
      String stage,
      String status,
      double? amount,
      int? probability,
      @JsonKey(name: 'expected_close') DateTime? expectedClose,
      String? description});
}

/// @nodoc
class _$DealCopyWithImpl<$Res, $Val extends Deal>
    implements $DealCopyWith<$Res> {
  _$DealCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? customerId = null,
    Object? contactId = freezed,
    Object? stage = null,
    Object? status = null,
    Object? amount = freezed,
    Object? probability = freezed,
    Object? expectedClose = freezed,
    Object? description = freezed,
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
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      contactId: freezed == contactId
          ? _value.contactId
          : contactId // ignore: cast_nullable_to_non_nullable
              as String?,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      probability: freezed == probability
          ? _value.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as int?,
      expectedClose: freezed == expectedClose
          ? _value.expectedClose
          : expectedClose // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DealImplCopyWith<$Res> implements $DealCopyWith<$Res> {
  factory _$$DealImplCopyWith(
          _$DealImpl value, $Res Function(_$DealImpl) then) =
      __$$DealImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'customer_id') String customerId,
      @JsonKey(name: 'contact_id') String? contactId,
      String stage,
      String status,
      double? amount,
      int? probability,
      @JsonKey(name: 'expected_close') DateTime? expectedClose,
      String? description});
}

/// @nodoc
class __$$DealImplCopyWithImpl<$Res>
    extends _$DealCopyWithImpl<$Res, _$DealImpl>
    implements _$$DealImplCopyWith<$Res> {
  __$$DealImplCopyWithImpl(_$DealImpl _value, $Res Function(_$DealImpl) _then)
      : super(_value, _then);

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? customerId = null,
    Object? contactId = freezed,
    Object? stage = null,
    Object? status = null,
    Object? amount = freezed,
    Object? probability = freezed,
    Object? expectedClose = freezed,
    Object? description = freezed,
  }) {
    return _then(_$DealImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      contactId: freezed == contactId
          ? _value.contactId
          : contactId // ignore: cast_nullable_to_non_nullable
              as String?,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      probability: freezed == probability
          ? _value.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as int?,
      expectedClose: freezed == expectedClose
          ? _value.expectedClose
          : expectedClose // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DealImpl implements _Deal {
  const _$DealImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'customer_id') required this.customerId,
      @JsonKey(name: 'contact_id') this.contactId,
      required this.stage,
      required this.status,
      this.amount,
      this.probability,
      @JsonKey(name: 'expected_close') this.expectedClose,
      this.description});

  factory _$DealImpl.fromJson(Map<String, dynamic> json) =>
      _$$DealImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  @JsonKey(name: 'contact_id')
  final String? contactId;
  @override
  final String stage;
  @override
  final String status;
  @override
  final double? amount;
  @override
  final int? probability;
  @override
  @JsonKey(name: 'expected_close')
  final DateTime? expectedClose;
  @override
  final String? description;

  @override
  String toString() {
    return 'Deal(id: $id, title: $title, customerId: $customerId, contactId: $contactId, stage: $stage, status: $status, amount: $amount, probability: $probability, expectedClose: $expectedClose, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DealImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.contactId, contactId) ||
                other.contactId == contactId) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.expectedClose, expectedClose) ||
                other.expectedClose == expectedClose) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, customerId, contactId,
      stage, status, amount, probability, expectedClose, description);

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DealImplCopyWith<_$DealImpl> get copyWith =>
      __$$DealImplCopyWithImpl<_$DealImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DealImplToJson(
      this,
    );
  }
}

abstract class _Deal implements Deal {
  const factory _Deal(
      {required final String id,
      required final String title,
      @JsonKey(name: 'customer_id') required final String customerId,
      @JsonKey(name: 'contact_id') final String? contactId,
      required final String stage,
      required final String status,
      final double? amount,
      final int? probability,
      @JsonKey(name: 'expected_close') final DateTime? expectedClose,
      final String? description}) = _$DealImpl;

  factory _Deal.fromJson(Map<String, dynamic> json) = _$DealImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  @JsonKey(name: 'contact_id')
  String? get contactId;
  @override
  String get stage;
  @override
  String get status;
  @override
  double? get amount;
  @override
  int? get probability;
  @override
  @JsonKey(name: 'expected_close')
  DateTime? get expectedClose;
  @override
  String? get description;

  /// Create a copy of Deal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DealImplCopyWith<_$DealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
