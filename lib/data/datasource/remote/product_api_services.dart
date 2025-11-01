import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:product_list_app/core/constants.dart';
import 'package:product_list_app/data/model/product_model.dart';

class ProductApiServices {
  Future<List<ProductModel>> fetchProducts({required int limit,required int skip}) async {
    try{
      final url=Uri.parse('${Appconstants.baseurl}${Appconstants.productsendpoint}?limit=$limit&skip=$skip');
      final response=await http.get(url);
      if(response.statusCode==200){
        final Map<String,dynamic> data=jsonDecode(response.body);
        final List productsjson=data['products'];
        final List<ProductModel>products=productsjson.map((json)=>ProductModel.fromJson(json)).toList();
        return products;
        
      }
else{
  throw Exception("failed to fetch products Status: ${response.statusCode}");
 }
      }
      catch(e){
        print("error fetching product $e");
        rethrow;
      }

    }
    
  }
