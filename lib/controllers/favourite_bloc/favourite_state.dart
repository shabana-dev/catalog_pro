import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class FavouriteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavouriteInitial extends FavouriteState {}

class FavouriteLoading extends FavouriteState {}

class FavouriteLoaded extends FavouriteState {
  final List<int> favouriteIds;
  final List<ProductModel> favouriteProducts;
  
  FavouriteLoaded({
    required this.favouriteIds,
    required this.favouriteProducts,
  });

  @override
  List<Object?> get props => [favouriteIds, favouriteProducts];
}

class FavouriteError extends FavouriteState {
  final String message;
  FavouriteError(this.message);

  @override
  List<Object?> get props => [message];
}
