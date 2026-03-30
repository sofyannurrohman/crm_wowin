import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required String id,
    String? code,
    required String name,
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
    @JsonKey(name: 'checkin_radius') int? checkinRadius,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}
