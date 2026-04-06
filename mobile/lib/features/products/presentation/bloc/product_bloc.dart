import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_product_detail.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final GetProductDetail getProductDetail;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  ProductBloc({
    required this.getProducts,
    required this.getProductDetail,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<FetchProductDetail>(_onFetchProductDetail);
    on<CreateProductSubmitted>(_onCreateProduct);
    on<UpdateProductSubmitted>(_onUpdateProduct);
    on<DeleteProductSubmitted>(_onDeleteProduct);
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

  Future<void> _onCreateProduct(
    CreateProductSubmitted event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductOperationLoading());
    final result = await createProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductOperationSuccess('Produk berhasil ditambahkan')),
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductSubmitted event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductOperationLoading());
    final result = await updateProduct(event.product);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductOperationSuccess('Produk berhasil diperbarui')),
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductSubmitted event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductOperationLoading());
    final result = await deleteProduct(event.id);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductOperationSuccess('Produk berhasil dihapus')),
    );
  }
}

