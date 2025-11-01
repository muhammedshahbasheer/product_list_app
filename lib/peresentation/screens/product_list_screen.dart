import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_list_app/data/model/product_model.dart';
import 'package:product_list_app/data/repositories/product_repository_impl.dart';
import 'package:product_list_app/peresentation/bloc/product_bloc.dart';
import 'package:product_list_app/peresentation/screens/product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  final ProductRepositoryImpl repository;
  const ProductListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductBloc(repository)..add(ProductEvent.fetchProducts()),
      child: Scaffold(
        appBar: AppBar(title: const Text("product app")),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(child: Text(message)),
              orElse: () {
                // Reactive Hive listener
                return StreamBuilder<List<ProductModel>>(
                  stream: repository.streamproducts(),
                  builder: (context, snapshot) {
                    final products = snapshot.data ?? [];

                    if (products.isEmpty) {
                      return const Center(child: Text('No products available.'));
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                          context
                              .read<ProductBloc>()
                              .add(const ProductEvent.loadMoreProducts());
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<ProductBloc>()
                              .add(const ProductEvent.refreshProducts());
                        },
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              elevation: 3,
                              child: ListTile(
                                leading: Image.network(
                                  product.thumbnail,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                ),
                                title: Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  '\$${product.price} ',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailScreen(product: product),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
