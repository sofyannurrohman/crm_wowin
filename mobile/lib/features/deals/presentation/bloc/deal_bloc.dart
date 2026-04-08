import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_deals.dart';
import '../../domain/usecases/get_deal_detail.dart';
import '../../domain/usecases/update_deal_stage.dart';
import '../../domain/usecases/get_deal_items.dart';
import '../../domain/usecases/add_deal_item.dart';
import '../../domain/usecases/remove_deal_item.dart';
import '../../domain/usecases/create_deal.dart';
import '../../domain/usecases/update_deal.dart';
import '../../domain/usecases/delete_deal.dart';
import 'deal_event.dart';
import 'deal_state.dart';

class DealBloc extends Bloc<DealEvent, DealState> {
  final GetDeals getDeals;
  final GetDealDetail getDealDetail;
  final UpdateDealStage updateDealStage;
  final GetDealItems getDealItems;
  final AddDealItem addDealItem;
  final RemoveDealItem removeDealItem;
  final CreateDeal createDeal;
  final UpdateDeal updateDeal;
  final DeleteDeal deleteDeal;

  DealBloc({
    required this.getDeals,
    required this.getDealDetail,
    required this.updateDealStage,
    required this.getDealItems,
    required this.addDealItem,
    required this.removeDealItem,
    required this.createDeal,
    required this.updateDeal,
    required this.deleteDeal,
  }) : super(DealInitial()) {
    on<FetchDeals>(_onFetchDeals);
    on<FetchDealDetail>(_onFetchDealDetail);
    on<UpdateDealStageSubmitted>(_onUpdateDealStageSubmitted);
    on<FetchDealItems>(_onFetchDealItems);
    on<AddDealItemSubmitted>(_onAddDealItemSubmitted);
    on<RemoveDealItemSubmitted>(_onRemoveDealItemSubmitted);
    on<CreateDealSubmitted>(_onCreateDealSubmitted);
    on<UpdateDealSubmitted>(_onUpdateDealSubmitted);
    on<DeleteDealSubmitted>(_onDeleteDealSubmitted);
  }

  Future<void> _onFetchDeals(
    FetchDeals event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await getDeals(customerId: event.customerId);
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (deals) => emit(DealsLoaded(deals)),
    );
  }

  Future<void> _onFetchDealDetail(
    FetchDealDetail event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    
    // Fetch deal detail (includes history in future, but currently just the deal)
    final dealResult = await getDealDetail(event.id);
    
    await dealResult.fold(
      (failure) async => emit(DealError(failure.message)),
      (deal) async {
        // Fetch items too
        final itemsResult = await getDealItems(event.id);
        itemsResult.fold(
          (failure) => emit(DealDetailLoaded(deal)), // items failed but deal ok
          (items) => emit(DealDetailLoaded(deal.copyWith(items: items))),
        );
      },
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
      (deal) =>
          emit(const DealOperationSuccess('Berhasil memperbarui tahapan deal')),
    );
  }

  Future<void> _onFetchDealItems(
    FetchDealItems event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await getDealItems(event.dealId);
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (items) => emit(DealItemsLoaded(items)),
    );
  }

  Future<void> _onAddDealItemSubmitted(
    AddDealItemSubmitted event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await addDealItem(
      dealId: event.dealId,
      productId: event.productId,
      name: event.name,
      quantity: event.quantity,
      price: event.price,
      unit: event.unit,
      discount: event.discount,
      notes: event.notes,
    );
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (item) {
        emit(const DealOperationSuccess('Berhasil menambahkan item'));
        add(FetchDealItems(event.dealId)); // Refresh
      },
    );
  }

  Future<void> _onRemoveDealItemSubmitted(
    RemoveDealItemSubmitted event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await removeDealItem(event.itemId);
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (_) {
        emit(const DealOperationSuccess('Item dihapus'));
        add(FetchDealItems(event.dealId)); // Refresh
      },
    );
  }

  Future<void> _onCreateDealSubmitted(
    CreateDealSubmitted event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await createDeal(event.deal);
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (deal) => emit(const DealOperationSuccess('Berhasil membuat deal baru')),
    );
  }

  Future<void> _onUpdateDealSubmitted(
    UpdateDealSubmitted event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await updateDeal(event.deal);
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (deal) => emit(const DealOperationSuccess('Berhasil memperbarui data deal')),
    );
  }

  Future<void> _onDeleteDealSubmitted(
    DeleteDealSubmitted event,
    Emitter<DealState> emit,
  ) async {
    emit(DealLoading());
    final result = await deleteDeal(event.id);
    result.fold(
      (failure) => emit(DealError(failure.message)),
      (_) => emit(const DealOperationSuccess('Berhasil menghapus data deal')),
    );
  }
}
