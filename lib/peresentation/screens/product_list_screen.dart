import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_list_app/domain/data/model/product_model.dart';
import 'package:product_list_app/domain/data/repositories/product_repository_impl.dart';
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
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
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
                        context.read<ProductBloc>().add(
                          const ProductEvent.refreshProducts(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              orElse: () {
                return BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, currentState) {
                    return StreamBuilder<List<ProductModel>>(
                      stream: repository.streamproducts(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<ProductBloc>().add(
                                      const ProductEvent.refreshProducts(),
                                    );
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final products = snapshot.data ?? [];

                        if (currentState.maybeWhen(
                          loading: () => true,
                          orElse: () => false,
                        )) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (products.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No products available.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<ProductBloc>().add(
                                      const ProductEvent.refreshProducts(),
                                    );
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
                              context.read<ProductBloc>().add(
                                const ProductEvent.loadMoreProducts(),
                              );
                            }
                            return false;
                          },
                          child: RefreshIndicator(
                            onRefresh: () async {
                              final completer = Completer<void>();
                              final bloc = context.read<ProductBloc>();
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
                            child: GridView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.75,
                                  ),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(
                                          product: product,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                          child: Image.network(
                                            product.thumbnail,
                                            height: 130,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '\$${product.price}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
