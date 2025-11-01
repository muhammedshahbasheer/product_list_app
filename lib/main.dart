import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:product_list_app/core/constants.dart';
import 'package:product_list_app/data/model/product_model.dart';

Future<void> main()async{
   WidgetsFlutterBinding.ensureInitialized();  await Hive.initFlutter();
Hive.registerAdapter(ProductModelAdapter());
await Hive.openBox<ProductModel>(Appconstants.hiveproductbox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(),
    );
  }
}


