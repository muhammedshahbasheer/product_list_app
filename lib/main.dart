import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:product_list_app/domain/data/datasource/local/product_local_storage.dart';
import 'package:product_list_app/domain/data/datasource/remote/product_api_services.dart';
import 'package:product_list_app/domain/data/model/product_model.dart';
import 'package:product_list_app/peresentation/screens/product_list_screen.dart';
import 'domain/data/repositories/product_repository_impl.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProductModelAdapter());
  await Hive.openBox<ProductModel>('product_box');
final apiService = ProductApiServices();
  final localStorage = ProductLocalStorage();
  final repository = ProductRepositoryImpl(apiService, localStorage);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ProductRepositoryImpl repository;

  const MyApp({Key? key, required this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductListScreen(repository: repository),
    );
  }
}