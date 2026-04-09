import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String salesId;
  final String? customerId;
  final String? leadId;
  final String shopName;
  final String content;
  final String dimensions;
  final String? photoPath;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BannerEntity({
    required this.id,
    required this.salesId,
    this.customerId,
    this.leadId,
    required this.shopName,
    required this.content,
    required this.dimensions,
    this.photoPath,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        salesId,
        customerId,
        leadId,
        shopName,
        content,
        dimensions,
        photoPath,
        latitude,
        longitude,
        address,
        createdAt,
        updatedAt,
      ];
}
