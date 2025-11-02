import 'package:product_list_app/core/constants.dart';
import 'package:product_list_app/domain/data/datasource/local/product_local_storage.dart';
import 'package:product_list_app/domain/data/datasource/remote/product_api_services.dart';
import 'package:product_list_app/domain/data/model/product_model.dart';

class ProductRepositoryImpl {
  final ProductApiServices _apiServices;
  final ProductLocalStorage _localStorage;
  ProductRepositoryImpl(this._apiServices, this._localStorage);
  Future<List<ProductModel>> fetchandcacheproducts({
    int limit = Appconstants.limit,
    int skip = Appconstants.skip,
  }) async {
    try {
      print("Fetching products: limit=$limit, skip=$skip");
      final products = await _apiServices.fetchProducts(
        limit: limit,
        skip: skip,
      );
      print("Fetched ${products.length} products");
      await _localStorage.saveproducts(products);
      print("Saved ${products.length} products to cache");
      return products;
    } catch (e, stackTrace) {
      print("Error fetching products: $e");
      print("Stack trace: $stackTrace");
      final cached = _localStorage.getallproducts();
      print("Found ${cached.length} cached products");
      if (cached.isEmpty) {
        print("No cached products available, rethrowing error");
        rethrow;
      }
      print("Returning ${cached.length} cached products");
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
