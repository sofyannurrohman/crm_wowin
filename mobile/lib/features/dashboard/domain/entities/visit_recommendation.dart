import 'package:freezed_annotation/freezed_annotation.dart';

part 'visit_recommendation.freezed.dart';
part 'visit_recommendation.g.dart';

@freezed
abstract class VisitRecommendation with _$VisitRecommendation {
  const factory VisitRecommendation({
    required String id,
    required String name,
    required String type, // "lead" or "customer"
    required String status, // "new", "stale", "scheduled"
    required String priority, // "high", "medium", "low"
    required String reason,
    @JsonKey(name: 'last_visit_at') String? lastVisitAt,
    @JsonKey(name: 'days_since_last') required int daysSinceLast,
    required String address,
    required double latitude,
    required double longitude,
  }) = _VisitRecommendation;

  factory VisitRecommendation.fromJson(Map<String, dynamic> json) =>
      _$VisitRecommendationFromJson(json);
}
