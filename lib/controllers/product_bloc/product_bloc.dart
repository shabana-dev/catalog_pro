import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/local_database.dart';
import '../../core/di/service_locator.dart';
import '../../models/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';
import 'dart:async';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService _apiService;
  final LocalDatabase _localDatabase = getIt<LocalDatabase>();
  final Connectivity _connectivity = Connectivity();

  ProductBloc(this._apiService) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onFetchProducts(FetchProducts event, Emitter<ProductState> emit) async {
    final isFirstFetch = state is! ProductLoaded || event.isRefresh;
    
    if (isFirstFetch) {
      emit(ProductLoading(isFirstFetch: true));
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    final isOffline = connectivityResult.contains(ConnectivityResult.none);

    try {
      if (isOffline) {
        try {
          final cached = await _localDatabase.getCachedProducts();
          final products = cached.map((e) => ProductModel.fromJson(e)).toList();
          emit(ProductLoaded(
            products: products,
            hasReachedMax: true,
            isOffline: true,
          ));
        } catch (dbError) {
          emit(ProductError('Offline mode error: $dbError'));
        }
        return;
      }

      final int skip = event.isRefresh ? 0 : (state is ProductLoaded ? (state as ProductLoaded).products.length : 0);
      final response = await _apiService.getProducts(limit: 20, skip: skip);
      final List<dynamic> data = response.data['products'];
      final newProducts = data.map((e) => ProductModel.fromJson(e)).toList();

      if (event.isRefresh || skip == 0) {
         // Run caching in background and ignore errors to keep UI working
         _localDatabase.cacheProducts(data).catchError((e) {
           debugPrint('Background caching failed: $e');
         });
      }

      if (state is ProductLoaded && !event.isRefresh) {
        final currentState = state as ProductLoaded;
        emit(ProductLoaded(
          products: currentState.products + newProducts,
          hasReachedMax: newProducts.isEmpty,
          isOffline: false,
        ));
      } else {
        emit(ProductLoaded(
          products: newProducts,
          hasReachedMax: newProducts.isEmpty,
          isOffline: false,
        ));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading(isFirstFetch: true));
    try {
      final response = await _apiService.searchProducts(event.query);
      final List<dynamic> data = response.data['products'];
      final products = data.map((e) => ProductModel.fromJson(e)).toList();
      emit(ProductLoaded(products: products, hasReachedMax: true));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
