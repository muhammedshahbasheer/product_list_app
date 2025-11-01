import 'package:product_list_app/core/constants.dart';
import 'package:product_list_app/data/datasource/local/product_local_storage.dart';
import 'package:product_list_app/data/datasource/remote/product_api_services.dart';
import 'package:product_list_app/data/model/product_model.dart';

class ProductRepositoryImpl {
  final ProductApiServices _apiServices;
  final ProductLocalStorage _localStorage;
  ProductRepositoryImpl(this._apiServices, this._localStorage);
  Future<List<ProductModel>> fetchandcacheproducts({
    int limit = Appconstants.limit,
    int skip = Appconstants.skip,
  }) async {
    try {
      final products = await _apiServices.fetchProducts(
        limit: limit,
        skip: skip,
      );
      await _localStorage.saveproducts(products);
      return products;
    } catch (e) {
      print("error fetching products $e");
      final cached = _localStorage.getallproducts();
      return cached;
    }
  }

  List<ProductModel> getlocalproducts() {
    return _localStorage.getallproducts();
  }

  Stream<List<ProductModel>> streamproducts() {
    return _localStorage.watchproducts();
  }

  Future<void> clearcache() async {
    await _localStorage.clearproduct();
  }
}
