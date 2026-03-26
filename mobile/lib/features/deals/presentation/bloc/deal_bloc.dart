import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_deals.dart';
import '../../domain/usecases/update_deal_stage.dart';
import 'deal_event.dart';
import 'deal_state.dart';

class DealBloc extends Bloc<DealEvent, DealState> {
  final GetDeals getDeals;
  final UpdateDealStage updateDealStage;

  DealBloc({
    required this.getDeals,
    required this.updateDealStage,
  }) : super(DealInitial()) {
    on<FetchDeals>(_onFetchDeals);
    on<UpdateDealStageSubmitted>(_onUpdateDealStageSubmitted);
  }

  Future<void> _onFetchDeals(
    FetchDeals event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await getDeals();
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (deals) => emit(DealsLoaded(deals)),
    );
  }

  Future<void> _onUpdateDealStageSubmitted(
    UpdateDealStageSubmitted event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await updateDealStage(event.id, event.stage);
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (deal) => emit(const DealOperationSuccess('Berhasil memperbarui tahapan deal')),
    );
  }
}
