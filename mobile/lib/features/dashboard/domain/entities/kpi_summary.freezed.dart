// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kpi_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

KpiSummary _$KpiSummaryFromJson(Map<String, dynamic> json) {
  return _KpiSummary.fromJson(json);
}

/// @nodoc
mixin _$KpiSummary {
  @JsonKey(name: 'total_sales')
  double get totalSales => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_leads')
  int get newLeads => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_deals')
  int get activeDeals => throw _privateConstructorUsedError;
  @JsonKey(name: 'visits_today')
  int get visitsToday => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_met_percentage')
  double get targetMetPercentage => throw _privateConstructorUsedError;

  /// Serializes this KpiSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KpiSummaryCopyWith<KpiSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KpiSummaryCopyWith<$Res> {
  factory $KpiSummaryCopyWith(
          KpiSummary value, $Res Function(KpiSummary) then) =
      _$KpiSummaryCopyWithImpl<$Res, KpiSummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_sales') double totalSales,
      @JsonKey(name: 'new_leads') int newLeads,
      @JsonKey(name: 'active_deals') int activeDeals,
      @JsonKey(name: 'visits_today') int visitsToday,
      @JsonKey(name: 'target_met_percentage') double targetMetPercentage});
}

/// @nodoc
class _$KpiSummaryCopyWithImpl<$Res, $Val extends KpiSummary>
    implements $KpiSummaryCopyWith<$Res> {
  _$KpiSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
  }) {
    return _then(_value.copyWith(
      totalSales: null == totalSales
          ? _value.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as double,
      newLeads: null == newLeads
          ? _value.newLeads
          : newLeads // ignore: cast_nullable_to_non_nullable
              as int,
      activeDeals: null == activeDeals
          ? _value.activeDeals
          : activeDeals // ignore: cast_nullable_to_non_nullable
              as int,
      visitsToday: null == visitsToday
          ? _value.visitsToday
          : visitsToday // ignore: cast_nullable_to_non_nullable
              as int,
      targetMetPercentage: null == targetMetPercentage
          ? _value.targetMetPercentage
          : targetMetPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KpiSummaryImplCopyWith<$Res>
    implements $KpiSummaryCopyWith<$Res> {
  factory _$$KpiSummaryImplCopyWith(
          _$KpiSummaryImpl value, $Res Function(_$KpiSummaryImpl) then) =
      __$$KpiSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_sales') double totalSales,
      @JsonKey(name: 'new_leads') int newLeads,
      @JsonKey(name: 'active_deals') int activeDeals,
      @JsonKey(name: 'visits_today') int visitsToday,
      @JsonKey(name: 'target_met_percentage') double targetMetPercentage});
}

/// @nodoc
class __$$KpiSummaryImplCopyWithImpl<$Res>
    extends _$KpiSummaryCopyWithImpl<$Res, _$KpiSummaryImpl>
    implements _$$KpiSummaryImplCopyWith<$Res> {
  __$$KpiSummaryImplCopyWithImpl(
      _$KpiSummaryImpl _value, $Res Function(_$KpiSummaryImpl) _then)
      : super(_value, _then);

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
  }) {
    return _then(_$KpiSummaryImpl(
      totalSales: null == totalSales
          ? _value.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as double,
      newLeads: null == newLeads
          ? _value.newLeads
          : newLeads // ignore: cast_nullable_to_non_nullable
              as int,
      activeDeals: null == activeDeals
          ? _value.activeDeals
          : activeDeals // ignore: cast_nullable_to_non_nullable
              as int,
      visitsToday: null == visitsToday
          ? _value.visitsToday
          : visitsToday // ignore: cast_nullable_to_non_nullable
              as int,
      targetMetPercentage: null == targetMetPercentage
          ? _value.targetMetPercentage
          : targetMetPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KpiSummaryImpl implements _KpiSummary {
  const _$KpiSummaryImpl(
      {@JsonKey(name: 'total_sales') required this.totalSales,
      @JsonKey(name: 'new_leads') required this.newLeads,
      @JsonKey(name: 'active_deals') required this.activeDeals,
      @JsonKey(name: 'visits_today') required this.visitsToday,
      @JsonKey(name: 'target_met_percentage')
      required this.targetMetPercentage});

  factory _$KpiSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$KpiSummaryImplFromJson(json);

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
  String toString() {
    return 'KpiSummary(totalSales: $totalSales, newLeads: $newLeads, activeDeals: $activeDeals, visitsToday: $visitsToday, targetMetPercentage: $targetMetPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KpiSummaryImpl &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.newLeads, newLeads) ||
                other.newLeads == newLeads) &&
            (identical(other.activeDeals, activeDeals) ||
                other.activeDeals == activeDeals) &&
            (identical(other.visitsToday, visitsToday) ||
                other.visitsToday == visitsToday) &&
            (identical(other.targetMetPercentage, targetMetPercentage) ||
                other.targetMetPercentage == targetMetPercentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalSales, newLeads,
      activeDeals, visitsToday, targetMetPercentage);

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KpiSummaryImplCopyWith<_$KpiSummaryImpl> get copyWith =>
      __$$KpiSummaryImplCopyWithImpl<_$KpiSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KpiSummaryImplToJson(
      this,
    );
  }
}

abstract class _KpiSummary implements KpiSummary {
  const factory _KpiSummary(
      {@JsonKey(name: 'total_sales') required final double totalSales,
      @JsonKey(name: 'new_leads') required final int newLeads,
      @JsonKey(name: 'active_deals') required final int activeDeals,
      @JsonKey(name: 'visits_today') required final int visitsToday,
      @JsonKey(name: 'target_met_percentage')
      required final double targetMetPercentage}) = _$KpiSummaryImpl;

  factory _KpiSummary.fromJson(Map<String, dynamic> json) =
      _$KpiSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'total_sales')
  double get totalSales;
  @override
  @JsonKey(name: 'new_leads')
  int get newLeads;
  @override
  @JsonKey(name: 'active_deals')
  int get activeDeals;
  @override
  @JsonKey(name: 'visits_today')
  int get visitsToday;
  @override
  @JsonKey(name: 'target_met_percentage')
  double get targetMetPercentage;

  /// Create a copy of KpiSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KpiSummaryImplCopyWith<_$KpiSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
