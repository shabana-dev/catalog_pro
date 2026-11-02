import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class FavouriteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavourites extends FavouriteEvent {}

class ToggleFavourite extends FavouriteEvent {
  final ProductModel product;
  ToggleFavourite(this.product);

  @override
  List<Object?> get props => [product];
}
