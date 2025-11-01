import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:product_list_app/core/constants.dart';
import 'package:product_list_app/data/model/product_model.dart';

class ProductLocalStorage {
  final Box<ProductModel> _productBox = Hive.box<ProductModel>(
    Appconstants.hiveproductbox,
  );
  Future<void> saveproducts(List<ProductModel> products) async {
    // Clear first, then use putAll for efficient batch write
    await _productBox.clear();
    // Use putAll for efficient batch write (creates a Map from the list)
    final Map<int, ProductModel> productsMap = {
      for (var product in products) product.id: product
    };
    await _productBox.putAll(productsMap);
  }

  Future<void> addproducts(List<ProductModel> products) async {
    // Use putAll for efficient batch write
    final Map<int, ProductModel> productsMap = {
      for (var product in products) product.id: product
    };
    await _productBox.putAll(productsMap);
  }

  List<ProductModel> getallproducts() {
    return _productBox.values.toList();
  }

  Stream<List<ProductModel>> watchproducts() {
    // Emit initial value immediately, then watch for changes
    return Stream.multi((controller) {
      // Emit current state immediately
      controller.add(_productBox.values.toList());
      // Then watch for changes
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
