import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/banner_repository_impl.dart';
import 'banner_event.dart';
import 'banner_state.dart';

class BannerBloc extends Bloc<BannerEvent, BannerState> {
  final BannerRepository repository;

  BannerBloc({required this.repository}) : super(BannerInitial()) {
    on<CreateBannerSubmitted>(_onCreateBanner);
    on<FetchBanners>(_onFetchBanners);
  }

  Future<void> _onCreateBanner(
    CreateBannerSubmitted event,
    Emitter<BannerState> emit,
  ) async {
    emit(BannerLoading());
    final result = await repository.createBanner(
      shopName: event.shopName,
      content: event.content,
      dimensions: event.dimensions,
      latitude: event.latitude,
      longitude: event.longitude,
      address: event.address,
      customerId: event.customerId,
      leadId: event.leadId,
      photo: event.photo,
    );

    result.fold(
      (failure) => emit(BannerError(failure.message)),
      (banner) => emit(BannerSuccess(banner, 'Data spanduk berhasil disimpan')),
    );
  }

  Future<void> _onFetchBanners(
    FetchBanners event,
    Emitter<BannerState> emit,
  ) async {
    emit(BannerLoading());
    final result = await repository.getBanners(
      salesId: event.salesId,
      customerId: event.customerId,
      leadId: event.leadId,
    );

    result.fold(
      (failure) => emit(BannerError(failure.message)),
      (banners) => emit(BannersLoaded(banners)),
    );
  }
}
