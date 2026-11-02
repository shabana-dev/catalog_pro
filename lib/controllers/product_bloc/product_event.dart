import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProducts extends ProductEvent {
  final bool isRefresh;
  FetchProducts({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SearchProducts extends ProductEvent {
  final String query;
  SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}
