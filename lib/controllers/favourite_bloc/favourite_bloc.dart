import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/local_database.dart';
import '../../core/di/service_locator.dart';
import 'favourite_event.dart';
import 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  final LocalDatabase _localDatabase = getIt<LocalDatabase>();

  FavouriteBloc() : super(FavouriteInitial()) {
    on<LoadFavourites>(_onLoadFavourites);
    on<ToggleFavourite>(_onToggleFavourite);
  }

  Future<void> _onLoadFavourites(LoadFavourites event, Emitter<FavouriteState> emit) async {
    emit(FavouriteLoading());
    try {
      final ids = await _localDatabase.getFavouriteIds();
      final products = await _localDatabase.getFavouriteProducts();
      emit(FavouriteLoaded(
        favouriteIds: ids,
        favouriteProducts: products,
      ));
    } catch (e) {
      emit(FavouriteError(e.toString()));
    }
  }

  Future<void> _onToggleFavourite(ToggleFavourite event, Emitter<FavouriteState> emit) async {
    try {
      await _localDatabase.toggleFavourite(event.product);
      final ids = await _localDatabase.getFavouriteIds();
      final products = await _localDatabase.getFavouriteProducts();
      emit(FavouriteLoaded(
        favouriteIds: ids,
        favouriteProducts: products,
      ));
    } catch (e) {
      emit(FavouriteError(e.toString()));
    }
  }
}
