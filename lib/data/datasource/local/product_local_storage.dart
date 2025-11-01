import 'package:hive_flutter/hive_flutter.dart';
import 'package:product_list_app/core/constants.dart';
import 'package:product_list_app/data/model/product_model.dart';

class ProductLocalStorage {
  final Box<ProductModel> _Productbox = Hive.box<ProductModel>(
    Appconstants.hiveproductbox,
  );
  Future<void> saveproducts(List<ProductModel> products) async {
    await _Productbox.clear();
    for (var product in products) {
      await _Productbox.put(product.id, product);
    }
  }

  Future<void> addproducts(List<ProductModel> products) async {
    for (var product in products) {
      await _Productbox.put(product.id, product);
    }
  }

  List<ProductModel> getallproducts() {
    return _Productbox.values.toList();
  }

  Stream<List<ProductModel>> watchproducts() {
    return _Productbox.watch().map((_) => _Productbox.values.toList());
  }

  Future<void> clearproduct() async {
    await _Productbox.clear();
  }
}
