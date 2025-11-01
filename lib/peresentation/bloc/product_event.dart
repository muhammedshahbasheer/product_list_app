part of 'product_bloc.dart';

@freezed
class ProductEvent with _$ProductEvent {
  const factory ProductEvent.fetchProducts() = _FetchProducts;
  const factory ProductEvent.loadMoreProducts() = _LoadMoreProducts;
  const factory ProductEvent.refreshProducts() = _RefreshProducts;
}