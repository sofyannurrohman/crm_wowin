// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visit_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VisitRecommendation {
  String get id;
  String get name;
  String get type; // "lead" or "customer"
  String get status; // "new", "stale", "scheduled"
  String get priority; // "high", "medium", "low"
  String get reason;
  @JsonKey(name: 'last_visit_at')
  String? get lastVisitAt;
  @JsonKey(name: 'days_since_last')
  int get daysSinceLast;
  String get address;
  double get latitude;
  double get longitude;

  /// Create a copy of VisitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VisitRecommendationCopyWith<VisitRecommendation> get copyWith =>
      _$VisitRecommendationCopyWithImpl<VisitRecommendation>(
          this as VisitRecommendation, _$identity);

  /// Serializes this VisitRecommendation to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VisitRecommendation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.lastVisitAt, lastVisitAt) ||
                other.lastVisitAt == lastVisitAt) &&
            (identical(other.daysSinceLast, daysSinceLast) ||
                other.daysSinceLast == daysSinceLast) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, status, priority,
      reason, lastVisitAt, daysSinceLast, address, latitude, longitude);

  @override
  String toString() {
    return 'VisitRecommendation(id: $id, name: $name, type: $type, status: $status, priority: $priority, reason: $reason, lastVisitAt: $lastVisitAt, daysSinceLast: $daysSinceLast, address: $address, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class $VisitRecommendationCopyWith<$Res> {
  factory $VisitRecommendationCopyWith(
          VisitRecommendation value, $Res Function(VisitRecommendation) _then) =
      _$VisitRecommendationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String status,
      String priority,
      String reason,
      @JsonKey(name: 'last_visit_at') String? lastVisitAt,
      @JsonKey(name: 'days_since_last') int daysSinceLast,
      String address,
      double latitude,
      double longitude});
}

/// @nodoc
class _$VisitRecommendationCopyWithImpl<$Res>
    implements $VisitRecommendationCopyWith<$Res> {
  _$VisitRecommendationCopyWithImpl(this._self, this._then);

  final VisitRecommendation _self;
  final $Res Function(VisitRecommendation) _then;

  /// Create a copy of VisitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? priority = null,
    Object? reason = null,
    Object? lastVisitAt = freezed,
    Object? daysSinceLast = null,
    Object? address = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      lastVisitAt: freezed == lastVisitAt
          ? _self.lastVisitAt
          : lastVisitAt // ignore: cast_nullable_to_non_nullable
              as String?,
      daysSinceLast: null == daysSinceLast
          ? _self.daysSinceLast
          : daysSinceLast // ignore: cast_nullable_to_non_nullable
              as int,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [VisitRecommendation].
extension VisitRecommendationPatterns on VisitRecommendation {
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
    TResult Function(_VisitRecommendation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VisitRecommendation() when $default != null:
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
    TResult Function(_VisitRecommendation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VisitRecommendation():
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
    TResult? Function(_VisitRecommendation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VisitRecommendation() when $default != null:
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
            String name,
            String type,
            String status,
            String priority,
            String reason,
            @JsonKey(name: 'last_visit_at') String? lastVisitAt,
            @JsonKey(name: 'days_since_last') int daysSinceLast,
            String address,
            double latitude,
            double longitude)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VisitRecommendation() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.type,
            _that.status,
            _that.priority,
            _that.reason,
            _that.lastVisitAt,
            _that.daysSinceLast,
            _that.address,
            _that.latitude,
            _that.longitude);
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
            String name,
            String type,
            String status,
            String priority,
            String reason,
            @JsonKey(name: 'last_visit_at') String? lastVisitAt,
            @JsonKey(name: 'days_since_last') int daysSinceLast,
            String address,
            double latitude,
            double longitude)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VisitRecommendation():
        return $default(
            _that.id,
            _that.name,
            _that.type,
            _that.status,
            _that.priority,
            _that.reason,
            _that.lastVisitAt,
            _that.daysSinceLast,
            _that.address,
            _that.latitude,
            _that.longitude);
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
            String name,
            String type,
            String status,
            String priority,
            String reason,
            @JsonKey(name: 'last_visit_at') String? lastVisitAt,
            @JsonKey(name: 'days_since_last') int daysSinceLast,
            String address,
            double latitude,
            double longitude)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VisitRecommendation() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.type,
            _that.status,
            _that.priority,
            _that.reason,
            _that.lastVisitAt,
            _that.daysSinceLast,
            _that.address,
            _that.latitude,
            _that.longitude);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _VisitRecommendation implements VisitRecommendation {
  const _VisitRecommendation(
      {required this.id,
      required this.name,
      required this.type,
      required this.status,
      required this.priority,
      required this.reason,
      @JsonKey(name: 'last_visit_at') this.lastVisitAt,
      @JsonKey(name: 'days_since_last') required this.daysSinceLast,
      required this.address,
      required this.latitude,
      required this.longitude});
  factory _VisitRecommendation.fromJson(Map<String, dynamic> json) =>
      _$VisitRecommendationFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
// "lead" or "customer"
  @override
  final String status;
// "new", "stale", "scheduled"
  @override
  final String priority;
// "high", "medium", "low"
  @override
  final String reason;
  @override
  @JsonKey(name: 'last_visit_at')
  final String? lastVisitAt;
  @override
  @JsonKey(name: 'days_since_last')
  final int daysSinceLast;
  @override
  final String address;
  @override
  final double latitude;
  @override
  final double longitude;

  /// Create a copy of VisitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VisitRecommendationCopyWith<_VisitRecommendation> get copyWith =>
      __$VisitRecommendationCopyWithImpl<_VisitRecommendation>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VisitRecommendationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VisitRecommendation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.lastVisitAt, lastVisitAt) ||
                other.lastVisitAt == lastVisitAt) &&
            (identical(other.daysSinceLast, daysSinceLast) ||
                other.daysSinceLast == daysSinceLast) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type, status, priority,
      reason, lastVisitAt, daysSinceLast, address, latitude, longitude);

  @override
  String toString() {
    return 'VisitRecommendation(id: $id, name: $name, type: $type, status: $status, priority: $priority, reason: $reason, lastVisitAt: $lastVisitAt, daysSinceLast: $daysSinceLast, address: $address, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class _$VisitRecommendationCopyWith<$Res>
    implements $VisitRecommendationCopyWith<$Res> {
  factory _$VisitRecommendationCopyWith(_VisitRecommendation value,
          $Res Function(_VisitRecommendation) _then) =
      __$VisitRecommendationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String status,
      String priority,
      String reason,
      @JsonKey(name: 'last_visit_at') String? lastVisitAt,
      @JsonKey(name: 'days_since_last') int daysSinceLast,
      String address,
      double latitude,
      double longitude});
}

/// @nodoc
class __$VisitRecommendationCopyWithImpl<$Res>
    implements _$VisitRecommendationCopyWith<$Res> {
  __$VisitRecommendationCopyWithImpl(this._self, this._then);

  final _VisitRecommendation _self;
  final $Res Function(_VisitRecommendation) _then;

  /// Create a copy of VisitRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? status = null,
    Object? priority = null,
    Object? reason = null,
    Object? lastVisitAt = freezed,
    Object? daysSinceLast = null,
    Object? address = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_VisitRecommendation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      lastVisitAt: freezed == lastVisitAt
          ? _self.lastVisitAt
          : lastVisitAt // ignore: cast_nullable_to_non_nullable
              as String?,
      daysSinceLast: null == daysSinceLast
          ? _self.daysSinceLast
          : daysSinceLast // ignore: cast_nullable_to_non_nullable
              as int,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
