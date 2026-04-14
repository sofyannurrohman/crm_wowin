import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;

  InventoryBloc({required this.repository}) : super(const InventoryInitial()) {
    on<FetchInventory>((event, emit) async {
      emit(const InventoryLoading());
      try {
        final items = await repository.getMyInventory();
        emit(InventorySuccess(items: items));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });

    on<FetchTransfers>((event, emit) async {
      emit(const InventoryLoading());
      try {
        final transfers = await repository.getTransfers(status: event.status);
        emit(InventorySuccess(transfers: transfers));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });

    on<SubmitStockTransfer>((event, emit) async {
      emit(const InventoryLoading());
      try {
        await repository.createTransfer(event.transfer);
        final items = await repository.getMyInventory();
        final transfers = await repository.getTransfers();
        emit(InventorySuccess(
          items: items,
          transfers: transfers,
          message: 'Pemesanan stok berhasil diajukan dan menunggu konfirmasi admin.',
        ));
      } catch (e) {
        emit(InventoryError(e.toString()));
      }
    });
  }
}
