import 'dart:async';

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
              initial: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, 
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ProductBloc>()
                            .add(const ProductEvent.refreshProducts());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              orElse: () {
                // Reactive Hive listener
                return BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, currentState) {
                    return StreamBuilder<List<ProductModel>>(
                      stream: repository.streamproducts(),
                      builder: (context, snapshot) {
                        // Check for errors in the stream
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, 
                                    size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<ProductBloc>()
                                        .add(const ProductEvent.refreshProducts());
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final products = snapshot.data ?? [];
                        
                        // If we're in loading state, show loading indicator
                        if (currentState.maybeWhen(
                          loading: () => true,
                          orElse: () => false,
                        )) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined, 
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No products available.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<ProductBloc>()
                                    .add(const ProductEvent.refreshProducts());
                              },
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      );
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
                          final completer = Completer<void>();
                          final bloc = context.read<ProductBloc>();
                          
                          // Listen to state changes to know when refresh is complete
                          final subscription = bloc.stream.listen((state) {
                            state.maybeWhen(
                              success: () {
                                if (!completer.isCompleted) {
                                  completer.complete();
                                }
                              },
                              error: (_) {
                                if (!completer.isCompleted) {
                                  completer.complete();
                                }
                              },
                              orElse: () {},
                            );
                          });
                          
                          bloc.add(const ProductEvent.refreshProducts());
                          await completer.future;
                          subscription.cancel();
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
            );
          },
        ),
      ),
    );
  }
}
