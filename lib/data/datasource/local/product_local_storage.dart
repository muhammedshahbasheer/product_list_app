import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:product_list_app/core/constants.dart';
import 'package:product_list_app/data/model/product_model.dart';

class ProductLocalStorage {
  final Box<ProductModel> _productBox = Hive.box<ProductModel>(
    Appconstants.hiveproductbox,
  );
  Future<void> saveproducts(List<ProductModel> products) async { 
    await _productBox.clear();
    final Map<int, ProductModel> productsMap = {
      for (var product in products) product.id: product
    };
    await _productBox.putAll(productsMap);
  }

  Future<void> addproducts(List<ProductModel> products) async {
    final Map<int, ProductModel> productsMap = {
      for (var product in products) product.id: product
    };
    await _productBox.putAll(productsMap);
  }

  List<ProductModel> getallproducts() {
    return _productBox.values.toList();
  }

  Stream<List<ProductModel>> watchproducts() {
    return Stream.multi((controller) {
      controller.add(_productBox.values.toList());
      final subscription = _productBox.watch().listen((_) {
        controller.add(_productBox.values.toList());
      });
      controller.onCancel = () => subscription.cancel();
    });
  }

  Future<void> clearproduct() async {
    await _productBox.clear();
  }
}
