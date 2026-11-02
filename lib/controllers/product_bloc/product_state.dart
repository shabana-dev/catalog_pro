import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {
  final bool isFirstFetch;
  ProductLoading({this.isFirstFetch = false});

  @override
  List<Object?> get props => [isFirstFetch];
}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final bool hasReachedMax;
  final bool isOffline;

  ProductLoaded({
    required this.products,
    required this.hasReachedMax,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [products, hasReachedMax, isOffline];
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
