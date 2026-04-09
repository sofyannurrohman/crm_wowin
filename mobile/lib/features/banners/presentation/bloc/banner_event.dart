import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class BannerEvent extends Equatable {
  const BannerEvent();

  @override
  List<Object?> get props => [];
}

class CreateBannerSubmitted extends BannerEvent {
  final String shopName;
  final String content;
  final String dimensions;
  final double latitude;
  final double longitude;
  final String? address;
  final String? customerId;
  final String? leadId;
  final File? photo;

  const CreateBannerSubmitted({
    required this.shopName,
    required this.content,
    required this.dimensions,
    required this.latitude,
    required this.longitude,
    this.address,
    this.customerId,
    this.leadId,
    this.photo,
  });

  @override
  List<Object?> get props => [
        shopName,
        content,
        dimensions,
        latitude,
        longitude,
        address,
        customerId,
        leadId,
        photo,
      ];
}

class FetchBanners extends BannerEvent {
  final String? salesId;
  final String? customerId;
  final String? leadId;

  const FetchBanners({this.salesId, this.customerId, this.leadId});

  @override
  List<Object?> get props => [salesId, customerId, leadId];
}
