import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProducts extends ProductEvent {
  final String? category;
  final String? query;

  const FetchProducts({this.category, this.query});

  @override
  List<Object?> get props => [category, query];
}

class FetchProductDetail extends ProductEvent {
  final String id;

  const FetchProductDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateProductSubmitted extends ProductEvent {
  final Product product;
  const CreateProductSubmitted(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductSubmitted extends ProductEvent {
  final Product product;
  const UpdateProductSubmitted(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductSubmitted extends ProductEvent {
  final String id;
  const DeleteProductSubmitted(this.id);

  @override
  List<Object?> get props => [id];
}
