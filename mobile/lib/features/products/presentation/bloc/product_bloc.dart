import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_product_detail.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final GetProductDetail getProductDetail;

  ProductBloc({
    required this.getProducts,
    required this.getProductDetail,
  }) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductDetail>(_onFetchProductDetail);
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getProducts(
      category: event.category,
      query: event.query,
    );
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onFetchProductDetail(
    FetchProductDetail event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await getProductDetail(event.id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }
}
