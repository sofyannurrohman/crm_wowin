// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kpi_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KpiSummary {
  @JsonKey(name: 'total_sales')
  double get totalSales;
  @JsonKey(name: 'new_leads')
  int get newLeads;
  @JsonKey(name: 'active_deals')
  int get activeDeals;
  @JsonKey(name: 'visits_today')
  int get visitsToday;
  @JsonKey(name: 'target_met_percentage')
  double get targetMetPercentage;
  @JsonKey(name: 'monthly_revenue')
  double get monthlyRevenue;
  @JsonKey(name: 'monthly_target')
  double get monthlyTarget;
  @JsonKey(name: 'visits_target')
  int get visitsTarget;
  @JsonKey(name: 'next_stop')
  VisitRecommendation? get nextStop;

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $KpiSummaryCopyWith<KpiSummary> get copyWith =>
      _$KpiSummaryCopyWithImpl<KpiSummary>(this as KpiSummary, _$identity);

  /// Serializes this KpiSummary to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is KpiSummary &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.newLeads, newLeads) ||
                other.newLeads == newLeads) &&
            (identical(other.activeDeals, activeDeals) ||
                other.activeDeals == activeDeals) &&
            (identical(other.visitsToday, visitsToday) ||
                other.visitsToday == visitsToday) &&
            (identical(other.targetMetPercentage, targetMetPercentage) ||
                other.targetMetPercentage == targetMetPercentage) &&
            (identical(other.monthlyRevenue, monthlyRevenue) ||
                other.monthlyRevenue == monthlyRevenue) &&
            (identical(other.monthlyTarget, monthlyTarget) ||
                other.monthlyTarget == monthlyTarget) &&
            (identical(other.visitsTarget, visitsTarget) ||
                other.visitsTarget == visitsTarget) &&
            (identical(other.nextStop, nextStop) ||
                other.nextStop == nextStop));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalSales,
      newLeads,
      activeDeals,
      visitsToday,
      targetMetPercentage,
      monthlyRevenue,
      monthlyTarget,
      visitsTarget,
      nextStop);

  @override
  String toString() {
    return 'KpiSummary(totalSales: $totalSales, newLeads: $newLeads, activeDeals: $activeDeals, visitsToday: $visitsToday, targetMetPercentage: $targetMetPercentage, monthlyRevenue: $monthlyRevenue, monthlyTarget: $monthlyTarget, visitsTarget: $visitsTarget, nextStop: $nextStop)';
  }
}

/// @nodoc
abstract mixin class $KpiSummaryCopyWith<$Res> {
  factory $KpiSummaryCopyWith(
          KpiSummary value, $Res Function(KpiSummary) _then) =
      _$KpiSummaryCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_sales') double totalSales,
      @JsonKey(name: 'new_leads') int newLeads,
      @JsonKey(name: 'active_deals') int activeDeals,
      @JsonKey(name: 'visits_today') int visitsToday,
      @JsonKey(name: 'target_met_percentage') double targetMetPercentage,
      @JsonKey(name: 'monthly_revenue') double monthlyRevenue,
      @JsonKey(name: 'monthly_target') double monthlyTarget,
      @JsonKey(name: 'visits_target') int visitsTarget,
      @JsonKey(name: 'next_stop') VisitRecommendation? nextStop});

  $VisitRecommendationCopyWith<$Res>? get nextStop;
}

/// @nodoc
class _$KpiSummaryCopyWithImpl<$Res> implements $KpiSummaryCopyWith<$Res> {
  _$KpiSummaryCopyWithImpl(this._self, this._then);

  final KpiSummary _self;
  final $Res Function(KpiSummary) _then;

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSales = null,
    Object? newLeads = null,
    Object? activeDeals = null,
    Object? visitsToday = null,
    Object? targetMetPercentage = null,
    Object? monthlyRevenue = null,
    Object? monthlyTarget = null,
    Object? visitsTarget = null,
    Object? nextStop = freezed,
  }) {
    return _then(_self.copyWith(
      totalSales: null == totalSales
          ? _self.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as double,
      newLeads: null == newLeads
          ? _self.newLeads
          : newLeads // ignore: cast_nullable_to_non_nullable
              as int,
      activeDeals: null == activeDeals
          ? _self.activeDeals
          : activeDeals // ignore: cast_nullable_to_non_nullable
              as int,
      visitsToday: null == visitsToday
          ? _self.visitsToday
          : visitsToday // ignore: cast_nullable_to_non_nullable
              as int,
      targetMetPercentage: null == targetMetPercentage
          ? _self.targetMetPercentage
          : targetMetPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyRevenue: null == monthlyRevenue
          ? _self.monthlyRevenue
          : monthlyRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyTarget: null == monthlyTarget
          ? _self.monthlyTarget
          : monthlyTarget // ignore: cast_nullable_to_non_nullable
              as double,
      visitsTarget: null == visitsTarget
          ? _self.visitsTarget
          : visitsTarget // ignore: cast_nullable_to_non_nullable
              as int,
      nextStop: freezed == nextStop
          ? _self.nextStop
          : nextStop // ignore: cast_nullable_to_non_nullable
              as VisitRecommendation?,
    ));
  }

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VisitRecommendationCopyWith<$Res>? get nextStop {
    if (_self.nextStop == null) {
      return null;
    }

    return $VisitRecommendationCopyWith<$Res>(_self.nextStop!, (value) {
      return _then(_self.copyWith(nextStop: value));
    });
  }
}

/// Adds pattern-matching-related methods to [KpiSummary].
extension KpiSummaryPatterns on KpiSummary {
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
    TResult Function(_KpiSummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _KpiSummary() when $default != null:
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
    TResult Function(_KpiSummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KpiSummary():
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
    TResult? Function(_KpiSummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KpiSummary() when $default != null:
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
            @JsonKey(name: 'total_sales') double totalSales,
            @JsonKey(name: 'new_leads') int newLeads,
            @JsonKey(name: 'active_deals') int activeDeals,
            @JsonKey(name: 'visits_today') int visitsToday,
            @JsonKey(name: 'target_met_percentage') double targetMetPercentage,
            @JsonKey(name: 'monthly_revenue') double monthlyRevenue,
            @JsonKey(name: 'monthly_target') double monthlyTarget,
            @JsonKey(name: 'visits_target') int visitsTarget,
            @JsonKey(name: 'next_stop') VisitRecommendation? nextStop)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _KpiSummary() when $default != null:
        return $default(
            _that.totalSales,
            _that.newLeads,
            _that.activeDeals,
            _that.visitsToday,
            _that.targetMetPercentage,
            _that.monthlyRevenue,
            _that.monthlyTarget,
            _that.visitsTarget,
            _that.nextStop);
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
            @JsonKey(name: 'total_sales') double totalSales,
            @JsonKey(name: 'new_leads') int newLeads,
            @JsonKey(name: 'active_deals') int activeDeals,
            @JsonKey(name: 'visits_today') int visitsToday,
            @JsonKey(name: 'target_met_percentage') double targetMetPercentage,
            @JsonKey(name: 'monthly_revenue') double monthlyRevenue,
            @JsonKey(name: 'monthly_target') double monthlyTarget,
            @JsonKey(name: 'visits_target') int visitsTarget,
            @JsonKey(name: 'next_stop') VisitRecommendation? nextStop)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KpiSummary():
        return $default(
            _that.totalSales,
            _that.newLeads,
            _that.activeDeals,
            _that.visitsToday,
            _that.targetMetPercentage,
            _that.monthlyRevenue,
            _that.monthlyTarget,
            _that.visitsTarget,
            _that.nextStop);
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
            @JsonKey(name: 'total_sales') double totalSales,
            @JsonKey(name: 'new_leads') int newLeads,
            @JsonKey(name: 'active_deals') int activeDeals,
            @JsonKey(name: 'visits_today') int visitsToday,
            @JsonKey(name: 'target_met_percentage') double targetMetPercentage,
            @JsonKey(name: 'monthly_revenue') double monthlyRevenue,
            @JsonKey(name: 'monthly_target') double monthlyTarget,
            @JsonKey(name: 'visits_target') int visitsTarget,
            @JsonKey(name: 'next_stop') VisitRecommendation? nextStop)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KpiSummary() when $default != null:
        return $default(
            _that.totalSales,
            _that.newLeads,
            _that.activeDeals,
            _that.visitsToday,
            _that.targetMetPercentage,
            _that.monthlyRevenue,
            _that.monthlyTarget,
            _that.visitsTarget,
            _that.nextStop);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _KpiSummary implements KpiSummary {
  const _KpiSummary(
      {@JsonKey(name: 'total_sales') required this.totalSales,
      @JsonKey(name: 'new_leads') required this.newLeads,
      @JsonKey(name: 'active_deals') required this.activeDeals,
      @JsonKey(name: 'visits_today') required this.visitsToday,
      @JsonKey(name: 'target_met_percentage') required this.targetMetPercentage,
      @JsonKey(name: 'monthly_revenue') required this.monthlyRevenue,
      @JsonKey(name: 'monthly_target') required this.monthlyTarget,
      @JsonKey(name: 'visits_target') required this.visitsTarget,
      @JsonKey(name: 'next_stop') this.nextStop});
  factory _KpiSummary.fromJson(Map<String, dynamic> json) =>
      _$KpiSummaryFromJson(json);

  @override
  @JsonKey(name: 'total_sales')
  final double totalSales;
  @override
  @JsonKey(name: 'new_leads')
  final int newLeads;
  @override
  @JsonKey(name: 'active_deals')
  final int activeDeals;
  @override
  @JsonKey(name: 'visits_today')
  final int visitsToday;
  @override
  @JsonKey(name: 'target_met_percentage')
  final double targetMetPercentage;
  @override
  @JsonKey(name: 'monthly_revenue')
  final double monthlyRevenue;
  @override
  @JsonKey(name: 'monthly_target')
  final double monthlyTarget;
  @override
  @JsonKey(name: 'visits_target')
  final int visitsTarget;
  @override
  @JsonKey(name: 'next_stop')
  final VisitRecommendation? nextStop;

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$KpiSummaryCopyWith<_KpiSummary> get copyWith =>
      __$KpiSummaryCopyWithImpl<_KpiSummary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$KpiSummaryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _KpiSummary &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.newLeads, newLeads) ||
                other.newLeads == newLeads) &&
            (identical(other.activeDeals, activeDeals) ||
                other.activeDeals == activeDeals) &&
            (identical(other.visitsToday, visitsToday) ||
                other.visitsToday == visitsToday) &&
            (identical(other.targetMetPercentage, targetMetPercentage) ||
                other.targetMetPercentage == targetMetPercentage) &&
            (identical(other.monthlyRevenue, monthlyRevenue) ||
                other.monthlyRevenue == monthlyRevenue) &&
            (identical(other.monthlyTarget, monthlyTarget) ||
                other.monthlyTarget == monthlyTarget) &&
            (identical(other.visitsTarget, visitsTarget) ||
                other.visitsTarget == visitsTarget) &&
            (identical(other.nextStop, nextStop) ||
                other.nextStop == nextStop));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalSales,
      newLeads,
      activeDeals,
      visitsToday,
      targetMetPercentage,
      monthlyRevenue,
      monthlyTarget,
      visitsTarget,
      nextStop);

  @override
  String toString() {
    return 'KpiSummary(totalSales: $totalSales, newLeads: $newLeads, activeDeals: $activeDeals, visitsToday: $visitsToday, targetMetPercentage: $targetMetPercentage, monthlyRevenue: $monthlyRevenue, monthlyTarget: $monthlyTarget, visitsTarget: $visitsTarget, nextStop: $nextStop)';
  }
}

/// @nodoc
abstract mixin class _$KpiSummaryCopyWith<$Res>
    implements $KpiSummaryCopyWith<$Res> {
  factory _$KpiSummaryCopyWith(
          _KpiSummary value, $Res Function(_KpiSummary) _then) =
      __$KpiSummaryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_sales') double totalSales,
      @JsonKey(name: 'new_leads') int newLeads,
      @JsonKey(name: 'active_deals') int activeDeals,
      @JsonKey(name: 'visits_today') int visitsToday,
      @JsonKey(name: 'target_met_percentage') double targetMetPercentage,
      @JsonKey(name: 'monthly_revenue') double monthlyRevenue,
      @JsonKey(name: 'monthly_target') double monthlyTarget,
      @JsonKey(name: 'visits_target') int visitsTarget,
      @JsonKey(name: 'next_stop') VisitRecommendation? nextStop});

  @override
  $VisitRecommendationCopyWith<$Res>? get nextStop;
}

/// @nodoc
class __$KpiSummaryCopyWithImpl<$Res> implements _$KpiSummaryCopyWith<$Res> {
  __$KpiSummaryCopyWithImpl(this._self, this._then);

  final _KpiSummary _self;
  final $Res Function(_KpiSummary) _then;

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalSales = null,
    Object? newLeads = null,
    Object? activeDeals = null,
    Object? visitsToday = null,
    Object? targetMetPercentage = null,
    Object? monthlyRevenue = null,
    Object? monthlyTarget = null,
    Object? visitsTarget = null,
    Object? nextStop = freezed,
  }) {
    return _then(_KpiSummary(
      totalSales: null == totalSales
          ? _self.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as double,
      newLeads: null == newLeads
          ? _self.newLeads
          : newLeads // ignore: cast_nullable_to_non_nullable
              as int,
      activeDeals: null == activeDeals
          ? _self.activeDeals
          : activeDeals // ignore: cast_nullable_to_non_nullable
              as int,
      visitsToday: null == visitsToday
          ? _self.visitsToday
          : visitsToday // ignore: cast_nullable_to_non_nullable
              as int,
      targetMetPercentage: null == targetMetPercentage
          ? _self.targetMetPercentage
          : targetMetPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyRevenue: null == monthlyRevenue
          ? _self.monthlyRevenue
          : monthlyRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyTarget: null == monthlyTarget
          ? _self.monthlyTarget
          : monthlyTarget // ignore: cast_nullable_to_non_nullable
              as double,
      visitsTarget: null == visitsTarget
          ? _self.visitsTarget
          : visitsTarget // ignore: cast_nullable_to_non_nullable
              as int,
      nextStop: freezed == nextStop
          ? _self.nextStop
          : nextStop // ignore: cast_nullable_to_non_nullable
              as VisitRecommendation?,
    ));
  }

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VisitRecommendationCopyWith<$Res>? get nextStop {
    if (_self.nextStop == null) {
      return null;
    }

    return $VisitRecommendationCopyWith<$Res>(_self.nextStop!, (value) {
      return _then(_self.copyWith(nextStop: value));
    });
  }
}

// dart format on
