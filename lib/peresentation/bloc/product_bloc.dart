import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:product_list_app/data/repositories/product_repository_impl.dart';

part 'product_event.dart';
part 'product_state.dart';
part 'product_bloc.freezed.dart';
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepositoryImpl repository;


  int _skip = 0;
  final int _limit = 10;

  ProductBloc(this.repository) : super(const ProductState.initial()) {

    on<_FetchProducts>((event, emit) async {
      emit(const ProductState.loading());
      try {
        await repository.fetchandcacheproducts(limit: _limit, skip: _skip);
        emit(const ProductState.success());
      } catch (e) {
        emit(ProductState.error('Error fetching products: $e'));
      }
    });

    on<_LoadMoreProducts>((event, emit) async {
      _skip += _limit;
      try {
        await repository.fetchandcacheproducts(limit: _limit, skip: _skip);
        emit(const ProductState.success());
      } catch (e) {
        emit(ProductState.error('Error loading more: $e'));
      }
    });

   
    on<_RefreshProducts>((event, emit) async {
      emit(const ProductState.loading());
      _skip = 0;
      try {
        await repository.fetchandcacheproducts(limit: _limit, skip: _skip);
        emit(const ProductState.success());
      } catch (e) {
        emit(ProductState.error('Error refreshing: $e'));
      }
    });
  }}