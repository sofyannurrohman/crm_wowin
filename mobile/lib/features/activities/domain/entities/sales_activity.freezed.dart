// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalesActivity {
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
  @JsonKey(name: 'type')
  String get activityType;
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
  @JsonKey(name: 'storefront_photo_base64')
  String? get storefrontPhotoBase64;
  String? get address;
  String? get outcome;
  Lead? get lead;
  Customer? get customer;
  Deal? get deal;

  /// Create a copy of SalesActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SalesActivityCopyWith<SalesActivity> get copyWith =>
      _$SalesActivityCopyWithImpl<SalesActivity>(
          this as SalesActivity, _$identity);

  /// Serializes this SalesActivity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SalesActivity &&
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
            (identical(other.storefrontPhotoBase64, storefrontPhotoBase64) ||
                other.storefrontPhotoBase64 == storefrontPhotoBase64) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.lead, lead) || other.lead == lead) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.deal, deal) || other.deal == deal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
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
        storefrontPhotoBase64,
        address,
        outcome,
        lead,
        customer,
        deal
      ]);

  @override
  String toString() {
    return 'SalesActivity(id: $id, title: $title, userId: $userId, leadId: $leadId, customerId: $customerId, dealId: $dealId, taskDestinationId: $taskDestinationId, activityType: $activityType, notes: $notes, activityAt: $activityAt, createdAt: $createdAt, updatedAt: $updatedAt, latitude: $latitude, longitude: $longitude, checkInTime: $checkInTime, checkOutTime: $checkOutTime, photoBase64: $photoBase64, storefrontPhotoBase64: $storefrontPhotoBase64, address: $address, outcome: $outcome, lead: $lead, customer: $customer, deal: $deal)';
  }
}

/// @nodoc
abstract mixin class $SalesActivityCopyWith<$Res> {
  factory $SalesActivityCopyWith(
          SalesActivity value, $Res Function(SalesActivity) _then) =
      _$SalesActivityCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'lead_id') String? leadId,
      @JsonKey(name: 'customer_id') String? customerId,
      @JsonKey(name: 'deal_id') String? dealId,
      @JsonKey(name: 'task_destination_id') String? taskDestinationId,
      @JsonKey(name: 'type') String activityType,
      String notes,
      @JsonKey(name: 'activity_at') DateTime activityAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'check_in_time') DateTime? checkInTime,
      @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
      @JsonKey(name: 'photo_base64') String? photoBase64,
      @JsonKey(name: 'storefront_photo_base64') String? storefrontPhotoBase64,
      String? address,
      String? outcome,
      Lead? lead,
      Customer? customer,
      Deal? deal});

  $LeadCopyWith<$Res>? get lead;
  $CustomerCopyWith<$Res>? get customer;
  $DealCopyWith<$Res>? get deal;
}

/// @nodoc
class _$SalesActivityCopyWithImpl<$Res>
    implements $SalesActivityCopyWith<$Res> {
  _$SalesActivityCopyWithImpl(this._self, this._then);

  final SalesActivity _self;
  final $Res Function(SalesActivity) _then;

  /// Create a copy of SalesActivity
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
    Object? storefrontPhotoBase64 = freezed,
    Object? address = freezed,
    Object? outcome = freezed,
    Object? lead = freezed,
    Object? customer = freezed,
    Object? deal = freezed,
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
      storefrontPhotoBase64: freezed == storefrontPhotoBase64
          ? _self.storefrontPhotoBase64
          : storefrontPhotoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      outcome: freezed == outcome
          ? _self.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as String?,
      lead: freezed == lead
          ? _self.lead
          : lead // ignore: cast_nullable_to_non_nullable
              as Lead?,
      customer: freezed == customer
          ? _self.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as Customer?,
      deal: freezed == deal
          ? _self.deal
          : deal // ignore: cast_nullable_to_non_nullable
              as Deal?,
    ));
  }

  /// Create a copy of SalesActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeadCopyWith<$Res>? get lead {
    if (_self.lead == null) {
      return null;
    }

    return $LeadCopyWith<$Res>(_self.lead!, (value) {
      return _then(_self.copyWith(lead: value));
    });
  }

  /// Create a copy of SalesActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerCopyWith<$Res>? get customer {
    if (_self.customer == null) {
      return null;
    }

    return $CustomerCopyWith<$Res>(_self.customer!, (value) {
      return _then(_self.copyWith(customer: value));
    });
  }

  /// Create a copy of SalesActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DealCopyWith<$Res>? get deal {
    if (_self.deal == null) {
      return null;
    }

    return $DealCopyWith<$Res>(_self.deal!, (value) {
      return _then(_self.copyWith(deal: value));
    });
  }
}

/// Adds pattern-matching-related methods to [SalesActivity].
extension SalesActivityPatterns on SalesActivity {
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
    TResult Function(_SalesActivity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SalesActivity() when $default != null:
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
    TResult Function(_SalesActivity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesActivity():
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
    TResult? Function(_SalesActivity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesActivity() when $default != null:
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
            @JsonKey(name: 'type') String activityType,
            String notes,
            @JsonKey(name: 'activity_at') DateTime activityAt,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'check_in_time') DateTime? checkInTime,
            @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
            @JsonKey(name: 'photo_base64') String? photoBase64,
            @JsonKey(name: 'storefront_photo_base64')
            String? storefrontPhotoBase64,
            String? address,
            String? outcome,
            Lead? lead,
            Customer? customer,
            Deal? deal)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SalesActivity() when $default != null:
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
            _that.storefrontPhotoBase64,
            _that.address,
            _that.outcome,
            _that.lead,
            _that.customer,
            _that.deal);
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
            @JsonKey(name: 'type') String activityType,
            String notes,
            @JsonKey(name: 'activity_at') DateTime activityAt,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'check_in_time') DateTime? checkInTime,
            @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
            @JsonKey(name: 'photo_base64') String? photoBase64,
            @JsonKey(name: 'storefront_photo_base64')
            String? storefrontPhotoBase64,
            String? address,
            String? outcome,
            Lead? lead,
            Customer? customer,
            Deal? deal)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesActivity():
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
            _that.storefrontPhotoBase64,
            _that.address,
            _that.outcome,
            _that.lead,
            _that.customer,
            _that.deal);
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
            @JsonKey(name: 'type') String activityType,
            String notes,
            @JsonKey(name: 'activity_at') DateTime activityAt,
            @JsonKey(name: 'created_at') DateTime? createdAt,
            @JsonKey(name: 'updated_at') DateTime? updatedAt,
            double? latitude,
            double? longitude,
            @JsonKey(name: 'check_in_time') DateTime? checkInTime,
            @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
            @JsonKey(name: 'photo_base64') String? photoBase64,
            @JsonKey(name: 'storefront_photo_base64')
            String? storefrontPhotoBase64,
            String? address,
            String? outcome,
            Lead? lead,
            Customer? customer,
            Deal? deal)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesActivity() when $default != null:
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
            _that.storefrontPhotoBase64,
            _that.address,
            _that.outcome,
            _that.lead,
            _that.customer,
            _that.deal);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SalesActivity extends SalesActivity {
  const _SalesActivity(
      {required this.id,
      required this.title,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'lead_id') this.leadId,
      @JsonKey(name: 'customer_id') this.customerId,
      @JsonKey(name: 'deal_id') this.dealId,
      @JsonKey(name: 'task_destination_id') this.taskDestinationId,
      @JsonKey(name: 'type') required this.activityType,
      required this.notes,
      @JsonKey(name: 'activity_at') required this.activityAt,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      this.latitude,
      this.longitude,
      @JsonKey(name: 'check_in_time') this.checkInTime,
      @JsonKey(name: 'check_out_time') this.checkOutTime,
      @JsonKey(name: 'photo_base64') this.photoBase64,
      @JsonKey(name: 'storefront_photo_base64') this.storefrontPhotoBase64,
      this.address,
      this.outcome,
      this.lead,
      this.customer,
      this.deal})
      : super._();
  factory _SalesActivity.fromJson(Map<String, dynamic> json) =>
      _$SalesActivityFromJson(json);

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
  @JsonKey(name: 'type')
  final String activityType;
  @override
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
  @JsonKey(name: 'storefront_photo_base64')
  final String? storefrontPhotoBase64;
  @override
  final String? address;
  @override
  final String? outcome;
  @override
  final Lead? lead;
  @override
  final Customer? customer;
  @override
  final Deal? deal;

  /// Create a copy of SalesActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SalesActivityCopyWith<_SalesActivity> get copyWith =>
      __$SalesActivityCopyWithImpl<_SalesActivity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SalesActivityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SalesActivity &&
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
            (identical(other.storefrontPhotoBase64, storefrontPhotoBase64) ||
                other.storefrontPhotoBase64 == storefrontPhotoBase64) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.lead, lead) || other.lead == lead) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.deal, deal) || other.deal == deal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
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
        storefrontPhotoBase64,
        address,
        outcome,
        lead,
        customer,
        deal
      ]);

  @override
  String toString() {
    return 'SalesActivity(id: $id, title: $title, userId: $userId, leadId: $leadId, customerId: $customerId, dealId: $dealId, taskDestinationId: $taskDestinationId, activityType: $activityType, notes: $notes, activityAt: $activityAt, createdAt: $createdAt, updatedAt: $updatedAt, latitude: $latitude, longitude: $longitude, checkInTime: $checkInTime, checkOutTime: $checkOutTime, photoBase64: $photoBase64, storefrontPhotoBase64: $storefrontPhotoBase64, address: $address, outcome: $outcome, lead: $lead, customer: $customer, deal: $deal)';
  }
}

/// @nodoc
abstract mixin class _$SalesActivityCopyWith<$Res>
    implements $SalesActivityCopyWith<$Res> {
  factory _$SalesActivityCopyWith(
          _SalesActivity value, $Res Function(_SalesActivity) _then) =
      __$SalesActivityCopyWithImpl;
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
      @JsonKey(name: 'type') String activityType,
      String notes,
      @JsonKey(name: 'activity_at') DateTime activityAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'check_in_time') DateTime? checkInTime,
      @JsonKey(name: 'check_out_time') DateTime? checkOutTime,
      @JsonKey(name: 'photo_base64') String? photoBase64,
      @JsonKey(name: 'storefront_photo_base64') String? storefrontPhotoBase64,
      String? address,
      String? outcome,
      Lead? lead,
      Customer? customer,
      Deal? deal});

  @override
  $LeadCopyWith<$Res>? get lead;
  @override
  $CustomerCopyWith<$Res>? get customer;
  @override
  $DealCopyWith<$Res>? get deal;
}

/// @nodoc
class __$SalesActivityCopyWithImpl<$Res>
    implements _$SalesActivityCopyWith<$Res> {
  __$SalesActivityCopyWithImpl(this._self, this._then);

  final _SalesActivity _self;
  final $Res Function(_SalesActivity) _then;

  /// Create a copy of SalesActivity
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
    Object? storefrontPhotoBase64 = freezed,
    Object? address = freezed,
    Object? outcome = freezed,
    Object? lead = freezed,
    Object? customer = freezed,
    Object? deal = freezed,
  }) {
    return _then(_SalesActivity(
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
      storefrontPhotoBase64: freezed == storefrontPhotoBase64
          ? _self.storefrontPhotoBase64
          : storefrontPhotoBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      outcome: freezed == outcome
          ? _self.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as String?,
      lead: freezed == lead
          ? _self.lead
          : lead // ignore: cast_nullable_to_non_nullable
              as Lead?,
      customer: freezed == customer
          ? _self.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as Customer?,
      deal: freezed == deal
          ? _self.deal
          : deal // ignore: cast_nullable_to_non_nullable
              as Deal?,
    ));
  }

  /// Create a copy of SalesActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeadCopyWith<$Res>? get lead {
    if (_self.lead == null) {
      return null;
    }

    return $LeadCopyWith<$Res>(_self.lead!, (value) {
      return _then(_self.copyWith(lead: value));
    });
  }

  /// Create a copy of SalesActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerCopyWith<$Res>? get customer {
    if (_self.customer == null) {
      return null;
    }

    return $CustomerCopyWith<$Res>(_self.customer!, (value) {
      return _then(_self.copyWith(customer: value));
    });
  }

  /// Create a copy of SalesActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DealCopyWith<$Res>? get deal {
    if (_self.deal == null) {
      return null;
    }

    return $DealCopyWith<$Res>(_self.deal!, (value) {
      return _then(_self.copyWith(deal: value));
    });
  }
}

// dart format on
