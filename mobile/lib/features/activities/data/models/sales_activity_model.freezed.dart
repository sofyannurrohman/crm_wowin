// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_activity_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalesActivityModel {
  String get id;
  String get title;
  @JsonKey(name: 'user_id')
  String get userId;
  @JsonKey(name: 'lead_id')
  String? get leadId;
  @JsonKey(name: 'customer_id')
  String? get customerId;
  @JsonKey(name: 'deal_id')
  String? get dealId;
  @JsonKey(name: 'task_destination_id')
  String? get taskDestinationId;
  @JsonKey(name: 'activity_type')
  String get activityType;
  @JsonKey(name: 'description')
  String get notes;
  @JsonKey(name: 'activity_at')
  DateTime get activityAt;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  double? get latitude;
  double? get longitude;
  @JsonKey(name: 'check_in_time')
  DateTime? get checkInTime;
  @JsonKey(name: 'check_out_time')
  DateTime? get checkOutTime;
  @JsonKey(name: 'photo_base64')
  String? get photoBase64;
  String? get outcome;

  /// Create a copy of SalesActivityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SalesActivityModelCopyWith<SalesActivityModel> get copyWith =>
      _$SalesActivityModelCopyWithImpl<SalesActivityModel>(
          this as SalesActivityModel, _$identity);

  /// Serializes this SalesActivityModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SalesActivityModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.leadId, leadId) || other.leadId == leadId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.taskDestinationId, taskDestinationId) ||
                other.taskDestinationId == taskDestinationId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.activityAt, activityAt) ||
                other.activityAt == activityAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.checkInTime, checkInTime) ||
                other.checkInTime == checkInTime) &&
            (identical(other.checkOutTime, checkOutTime) ||
                other.checkOutTime == checkOutTime) &&
            (identical(other.photoBase64, photoBase64) ||
                other.photoBase64 == photoBase64) &&
            (identical(other.outcome, outcome) || other.outcome == outcome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      userId,
      leadId,
      customerId,
      dealId,
      taskDestinationId,
      activityType,
      notes,
      activityAt,
      createdAt,
      updatedAt,
      latitude,
      longitude,
      checkInTime,
      checkOutTime,
      photoBase64,
      outcome);

  @override
  String toString() {
    return 'SalesActivityModel(id: $id, title: $title, userId: $userId, leadId: $leadId, customerId: $customerId, dealId: $dealId, taskDestinationId: $taskDestinationId, activityType: $activityType, notes: $notes, activityAt: $activityAt, createdAt: $createdAt, updatedAt: $updatedAt, latitude: $latitude, longitude: $longitude, checkInTime: $checkInTime, checkOutTime: $checkOutTime, photoBase64: $photoBase64, outcome: $outcome)';
  }
}

/// @nodoc
abstract mixin class $SalesActivityModelCopyWith<$Res> {
  factory $SalesActivityModelCopyWith(
          SalesActivityModel value, $Res Function(SalesActivityModel) _then) =
      _$SalesActivityModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'lead_id') String? leadId,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'deal_id') String? dealId,
      @JsonKey(name: 'task_destination_id') String? taskDestinationId,
      @JsonKey(name: 'activity_type') String activityType,
      @JsonKey(name: 'description') String notes,
      @JsonKey(name: 'activity_at') DateTime activityAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'check_in_time') DateTime? checkInTime,
      @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
      @JsonKey(name: 'photo_base64') String? photoBase64,
      String? outcome});
}

/// @nodoc
class _$SalesActivityModelCopyWithImpl<$Res>
    implements $SalesActivityModelCopyWith<$Res> {
  _$SalesActivityModelCopyWithImpl(this._self, this._then);

  final SalesActivityModel _self;
  final $Res Function(SalesActivityModel) _then;

  /// Create a copy of SalesActivityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? userId = null,
    Object? leadId = freezed,
    Object? customerId = freezed,
    Object? dealId = freezed,
    Object? taskDestinationId = freezed,
    Object? activityType = null,
    Object? notes = null,
    Object? activityAt = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? checkInTime = freezed,
    Object? checkOutTime = freezed,
    Object? photoBase64 = freezed,
    Object? outcome = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      leadId: freezed == leadId
          ? _self.leadId
          : leadId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      dealId: freezed == dealId
          ? _self.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as String?,
      taskDestinationId: freezed == taskDestinationId
          ? _self.taskDestinationId
          : taskDestinationId // ignore: cast_nullable_to_non_nullable
              as String?,
      activityType: null == activityType
          ? _self.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      activityAt: null == activityAt
          ? _self.activityAt
          : activityAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      checkInTime: freezed == checkInTime
          ? _self.checkInTime
          : checkInTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkOutTime: freezed == checkOutTime
          ? _self.checkOutTime
          : checkOutTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photoBase64: freezed == photoBase64
          ? _self.photoBase64
          : photoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      outcome: freezed == outcome
          ? _self.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SalesActivityModel].
extension SalesActivityModelPatterns on SalesActivityModel {
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
    TResult Function(_SalesActivityModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SalesActivityModel() when $default != null:
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
    TResult Function(_SalesActivityModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesActivityModel():
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
    TResult? Function(_SalesActivityModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesActivityModel() when $default != null:
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
            String title,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'lead_id') String? leadId,
            @JsonKey(name: 'customer_id') String? customerId,
            @JsonKey(name: 'deal_id') String? dealId,
            @JsonKey(name: 'task_destination_id') String? taskDestinationId,
            @JsonKey(name: 'activity_type') String activityType,
            @JsonKey(name: 'description') String notes,
            @JsonKey(name: 'activity_at') DateTime activityAt,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'check_in_time') DateTime? checkInTime,
            @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
            @JsonKey(name: 'photo_base64') String? photoBase64,
            String? outcome)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SalesActivityModel() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.userId,
            _that.leadId,
            _that.customerId,
            _that.dealId,
            _that.taskDestinationId,
            _that.activityType,
            _that.notes,
            _that.activityAt,
            _that.createdAt,
            _that.updatedAt,
            _that.latitude,
            _that.longitude,
            _that.checkInTime,
            _that.checkOutTime,
            _that.photoBase64,
            _that.outcome);
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
            String title,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'lead_id') String? leadId,
            @JsonKey(name: 'customer_id') String? customerId,
            @JsonKey(name: 'deal_id') String? dealId,
            @JsonKey(name: 'task_destination_id') String? taskDestinationId,
            @JsonKey(name: 'activity_type') String activityType,
            @JsonKey(name: 'description') String notes,
            @JsonKey(name: 'activity_at') DateTime activityAt,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'check_in_time') DateTime? checkInTime,
            @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
            @JsonKey(name: 'photo_base64') String? photoBase64,
            String? outcome)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesActivityModel():
        return $default(
            _that.id,
            _that.title,
            _that.userId,
            _that.leadId,
            _that.customerId,
            _that.dealId,
            _that.taskDestinationId,
            _that.activityType,
            _that.notes,
            _that.activityAt,
            _that.createdAt,
            _that.updatedAt,
            _that.latitude,
            _that.longitude,
            _that.checkInTime,
            _that.checkOutTime,
            _that.photoBase64,
            _that.outcome);
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
            String title,
            @JsonKey(name: 'user_id') String userId,
            @JsonKey(name: 'lead_id') String? leadId,
            @JsonKey(name: 'customer_id') String? customerId,
            @JsonKey(name: 'deal_id') String? dealId,
            @JsonKey(name: 'task_destination_id') String? taskDestinationId,
            @JsonKey(name: 'activity_type') String activityType,
            @JsonKey(name: 'description') String notes,
            @JsonKey(name: 'activity_at') DateTime activityAt,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'check_in_time') DateTime? checkInTime,
            @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
            @JsonKey(name: 'photo_base64') String? photoBase64,
            String? outcome)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesActivityModel() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.userId,
            _that.leadId,
            _that.customerId,
            _that.dealId,
            _that.taskDestinationId,
            _that.activityType,
            _that.notes,
            _that.activityAt,
            _that.createdAt,
            _that.updatedAt,
            _that.latitude,
            _that.longitude,
            _that.checkInTime,
            _that.checkOutTime,
            _that.photoBase64,
            _that.outcome);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SalesActivityModel extends SalesActivityModel {
  const _SalesActivityModel(
      {required this.id,
      required this.title,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'lead_id') this.leadId,
      @JsonKey(name: 'customer_id') this.customerId,
      @JsonKey(name: 'deal_id') this.dealId,
      @JsonKey(name: 'task_destination_id') this.taskDestinationId,
      @JsonKey(name: 'activity_type') required this.activityType,
      @JsonKey(name: 'description') required this.notes,
      @JsonKey(name: 'activity_at') required this.activityAt,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      this.latitude,
      this.longitude,
      @JsonKey(name: 'check_in_time') this.checkInTime,
      @JsonKey(name: 'check_out_time') this.checkOutTime,
      @JsonKey(name: 'photo_base64') this.photoBase64,
      this.outcome})
      : super._();
  factory _SalesActivityModel.fromJson(Map<String, dynamic> json) =>
      _$SalesActivityModelFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'lead_id')
  final String? leadId;
  @override
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @override
  @JsonKey(name: 'deal_id')
  final String? dealId;
  @override
  @JsonKey(name: 'task_destination_id')
  final String? taskDestinationId;
  @override
  @JsonKey(name: 'activity_type')
  final String activityType;
  @override
  @JsonKey(name: 'description')
  final String notes;
  @override
  @JsonKey(name: 'activity_at')
  final DateTime activityAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'check_in_time')
  final DateTime? checkInTime;
  @override
  @JsonKey(name: 'check_out_time')
  final DateTime? checkOutTime;
  @override
  @JsonKey(name: 'photo_base64')
  final String? photoBase64;
  @override
  final String? outcome;

  /// Create a copy of SalesActivityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SalesActivityModelCopyWith<_SalesActivityModel> get copyWith =>
      __$SalesActivityModelCopyWithImpl<_SalesActivityModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SalesActivityModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SalesActivityModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.leadId, leadId) || other.leadId == leadId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.dealId, dealId) || other.dealId == dealId) &&
            (identical(other.taskDestinationId, taskDestinationId) ||
                other.taskDestinationId == taskDestinationId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.activityAt, activityAt) ||
                other.activityAt == activityAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.checkInTime, checkInTime) ||
                other.checkInTime == checkInTime) &&
            (identical(other.checkOutTime, checkOutTime) ||
                other.checkOutTime == checkOutTime) &&
            (identical(other.photoBase64, photoBase64) ||
                other.photoBase64 == photoBase64) &&
            (identical(other.outcome, outcome) || other.outcome == outcome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      userId,
      leadId,
      customerId,
      dealId,
      taskDestinationId,
      activityType,
      notes,
      activityAt,
      createdAt,
      updatedAt,
      latitude,
      longitude,
      checkInTime,
      checkOutTime,
      photoBase64,
      outcome);

  @override
  String toString() {
    return 'SalesActivityModel(id: $id, title: $title, userId: $userId, leadId: $leadId, customerId: $customerId, dealId: $dealId, taskDestinationId: $taskDestinationId, activityType: $activityType, notes: $notes, activityAt: $activityAt, createdAt: $createdAt, updatedAt: $updatedAt, latitude: $latitude, longitude: $longitude, checkInTime: $checkInTime, checkOutTime: $checkOutTime, photoBase64: $photoBase64, outcome: $outcome)';
  }
}

/// @nodoc
abstract mixin class _$SalesActivityModelCopyWith<$Res>
    implements $SalesActivityModelCopyWith<$Res> {
  factory _$SalesActivityModelCopyWith(
          _SalesActivityModel value, $Res Function(_SalesActivityModel) _then) =
      __$SalesActivityModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'lead_id') String? leadId,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'deal_id') String? dealId,
      @JsonKey(name: 'task_destination_id') String? taskDestinationId,
      @JsonKey(name: 'activity_type') String activityType,
      @JsonKey(name: 'description') String notes,
      @JsonKey(name: 'activity_at') DateTime activityAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'check_in_time') DateTime? checkInTime,
      @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
      @JsonKey(name: 'photo_base64') String? photoBase64,
      String? outcome});
}

/// @nodoc
class __$SalesActivityModelCopyWithImpl<$Res>
    implements _$SalesActivityModelCopyWith<$Res> {
  __$SalesActivityModelCopyWithImpl(this._self, this._then);

  final _SalesActivityModel _self;
  final $Res Function(_SalesActivityModel) _then;

  /// Create a copy of SalesActivityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? userId = null,
    Object? leadId = freezed,
    Object? customerId = freezed,
    Object? dealId = freezed,
    Object? taskDestinationId = freezed,
    Object? activityType = null,
    Object? notes = null,
    Object? activityAt = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? checkInTime = freezed,
    Object? checkOutTime = freezed,
    Object? photoBase64 = freezed,
    Object? outcome = freezed,
  }) {
    return _then(_SalesActivityModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      leadId: freezed == leadId
          ? _self.leadId
          : leadId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      dealId: freezed == dealId
          ? _self.dealId
          : dealId // ignore: cast_nullable_to_non_nullable
              as String?,
      taskDestinationId: freezed == taskDestinationId
          ? _self.taskDestinationId
          : taskDestinationId // ignore: cast_nullable_to_non_nullable
              as String?,
      activityType: null == activityType
          ? _self.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      activityAt: null == activityAt
          ? _self.activityAt
          : activityAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      checkInTime: freezed == checkInTime
          ? _self.checkInTime
          : checkInTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkOutTime: freezed == checkOutTime
          ? _self.checkOutTime
          : checkOutTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      photoBase64: freezed == photoBase64
          ? _self.photoBase64
          : photoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      outcome: freezed == outcome
          ? _self.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
