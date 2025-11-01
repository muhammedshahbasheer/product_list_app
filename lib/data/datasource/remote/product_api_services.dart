import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:product_list_app/core/constants.dart';
import 'package:product_list_app/data/model/product_model.dart';

class ProductApiServices {
  Future<List<ProductModel>> fetchProducts({required int limit,required int skip}) async {
    try{
      final url=Uri.parse('${Appconstants.baseurl}${Appconstants.productsendpoint}?limit=$limit&skip=$skip');
      print("Fetching from URL: $url");
      final response=await http.get(url);
      print("Response status: ${response.statusCode}");
      if(response.statusCode==200){
        final Map<String,dynamic> data=jsonDecode(response.body);
        final List? productsjson=data['products'];
        if (productsjson == null) {
          throw Exception("Products key not found in response");
        }
        final List<ProductModel>products=productsjson.map((json)=>ProductModel.fromJson(json)).toList();
        print("Parsed ${products.length} products");
        return products;
      }
      else{
        throw Exception("Failed to fetch products. Status: ${response.statusCode}, Body: ${response.body}");
      }
    }
    catch(e, stackTrace){
      print("Error fetching products: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }
}