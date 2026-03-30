import 'package:equatable/equatable.dart';

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
