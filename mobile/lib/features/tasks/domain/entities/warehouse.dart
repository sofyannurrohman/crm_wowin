import 'package:equatable/equatable.dart';

class Warehouse extends Equatable {
  final String id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;

  const Warehouse({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [id, name, address, latitude, longitude];
}
