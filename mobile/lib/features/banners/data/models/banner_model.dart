import '../../domain/entities/banner.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.salesId,
    super.customerId,
    super.leadId,
    required super.shopName,
    required super.content,
    required super.dimensions,
    super.photoPath,
    required super.latitude,
    required super.longitude,
    super.address,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      salesId: json['sales_id'],
      customerId: json['customer_id'],
      leadId: json['lead_id'],
      shopName: json['shop_name'],
      content: json['content'],
      dimensions: json['dimensions'],
      photoPath: json['photo_path'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sales_id': salesId,
      'customer_id': customerId,
      'lead_id': leadId,
      'shop_name': shopName,
      'content': content,
      'dimensions': dimensions,
      'photo_path': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
