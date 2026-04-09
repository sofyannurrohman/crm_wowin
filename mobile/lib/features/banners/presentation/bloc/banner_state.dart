import 'package:equatable/equatable.dart';
import '../../domain/entities/banner.dart';

abstract class BannerState extends Equatable {
  const BannerState();

  @override
  List<Object?> get props => [];
}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannersLoaded extends BannerState {
  final List<BannerEntity> banners;

  const BannersLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

class BannerSuccess extends BannerState {
  final BannerEntity banner;
  final String message;

  const BannerSuccess(this.banner, this.message);

  @override
  List<Object?> get props => [banner, message];
}

class BannerError extends BannerState {
  final String message;

  const BannerError(this.message);

  @override
  List<Object?> get props => [message];
}
