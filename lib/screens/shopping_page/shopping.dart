import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application/config.dart';
import 'package:flutter_application/screens/shopping_page/product_card.dart';
import 'package:flutter_application/screens/shopping_page/section_header.dart';
import 'package:flutter_application/data/recommend_data.dart';
import 'package:flutter_application/data/latest_product.dart';
import 'package:flutter_application/shared/product_provider.dart';

const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFE6E0E9),
    Color(0xFFE6E0E9),
    Color(0xFFE6E0E9),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  late Future<List<Map<String, dynamic>>> _recommendProductsFuture;
  List<Map<String, dynamic>> _latestProducts = [];
  String? _nextCursor;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  bool _hasMoreProducts = true;
  bool _hasError = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRecommendProducts();
    _fetchInitialLatestProducts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreProducts) {
      _loadMoreLatestProducts();
    }
  }

  void _fetchRecommendProducts() {
    setState(() {
      _recommendProductsFuture = fetchRecommendProducts();
    });
  }

  Future<void> _fetchInitialLatestProducts() async {
    setState(() {
      _isInitialLoading = true;
      _hasError = false;
    });

    try {
      final result = await fetchLatestProducts();
      if (mounted) {
        setState(() {
          _latestProducts = result['items'];
          _nextCursor = result['nextCursor'];
          _hasMoreProducts = _nextCursor != null;
          _isInitialLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreLatestProducts() async {
    if (_isLoadingMore || !_hasMoreProducts) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await fetchLatestProducts(cursor: _nextCursor);
      if (mounted) {
        setState(() {
          _latestProducts.addAll(result['items']);
          _nextCursor = result['nextCursor'];
          _hasMoreProducts = _nextCursor != null;
          _isLoadingMore = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                SectionHeader(title: 'Recommend Product'),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _recommendProductsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SingleChildScrollView(child: _buildShimmer());
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return _buildErrorSection(
                          onRetry: _fetchRecommendProducts,
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              for (var product in snapshot.data!)
                                ProductCard(
                                  key: ValueKey(
                                      "${product['id']}-${product['name']}-${product['price']}-recommend}"),
                                  product: product,
                                  onAdd: () => _handleProductAdd(
                                      product, productProvider, "recommend"),
                                  onRemove: () => _handleProductRemove(
                                      product, productProvider, "recommend"),
                                ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SectionHeader(title: 'Latest Products'),
              _buildLatestProductsSection(productProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLatestProductsSection(ProductProvider productProvider) {
    if (_isInitialLoading) {
      return Column(
        children: [
          _buildShimmer(),
          _buildShimmer(),
        ],
      );
    }

    if (_hasError) {
      return _buildErrorSection(
        onRetry: _fetchInitialLatestProducts,
      );
    }

    return Column(
      children: [
        ..._latestProducts.map(
          (product) => ProductCard(
            key: ValueKey(
                "${product['id']}-${product['name']}-${product['price']}-latest}"),
            product: product,
            onAdd: () => _handleProductAdd(product, productProvider, "latest"),
            onRemove: () =>
                _handleProductRemove(product, productProvider, "latest"),
          ),
        ),
        if (_isLoadingMore) _buildShimmer(),
        if (!_hasMoreProducts && _latestProducts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No more products to load',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  Widget _buildShimmer() {
    double width = MediaQuery.sizeOf(context).width;
    return Column(
      children: List.generate(
        4,
        (index) => Shimmer(
          gradient: _shimmerGradient,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    height: 78,
                    width: 78,
                    decoration: BoxDecoration(
                      color: Color(0xFFE6E0E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        height: 20,
                        width: width / 2,
                        decoration: BoxDecoration(
                          color: Color(0xFFE6E0E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        height: 20,
                        width: width / 3,
                        decoration: BoxDecoration(
                          color: Color(0xFFE6E0E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSection({required VoidCallback onRetry}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Something went wrong",
          style: TextStyle(fontSize: 16, color: MainColors.errorColor),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: onRetry,
          child: const Text("Refresh"),
        ),
      ],
    );
  }

  void _handleProductAdd(
      Map<String, dynamic> product, ProductProvider provider, String type) {
    provider.increaseQuantity(
      product['id'],
      product['name'],
      product['price'].toString(),
      type,
    );
    _incrementQuantity(product['name'], product['id'], type);
  }

  void _handleProductRemove(
      Map<String, dynamic> product, ProductProvider provider, String type) {
    provider.decreaseQuantity(
      product['id'],
      product['name'],
      product['price'].toString(),
      type,
    );
    _decrementQuantity(product['name'], product['id'], type);
  }

  void _incrementQuantity(String name, int id, String productType) {
    setState(() {
      if (productType == "latest") {
        final product = _latestProducts.firstWhere((p) => p['id'] == id);
        product['quantity']++;
      } else {
        _recommendProductsFuture.then((products) {
          final product = products.firstWhere((p) => p['id'] == id);
          product['quantity']++;
        });
      }
    });
  }

  void _decrementQuantity(String name, int id, String productType) {
    setState(() {
      if (productType == "latest") {
        final product = _latestProducts.firstWhere((p) => p['id'] == id);
        product['quantity']--;
      } else {
        _recommendProductsFuture.then((products) {
          final product = products.firstWhere((p) => p['id'] == id);
          product['quantity']--;
        });
      }
    });
  }
}
// class ShoppingPage extends StatefulWidget {
//   const ShoppingPage({super.key});

//   @override
//   State<ShoppingPage> createState() => _ShoppingPageState();
// }

// class _ShoppingPageState extends State<ShoppingPage> {
//   late Future<List<Map<String, dynamic>>> _recommendProductsFuture;
//   late Future<List<Map<String, dynamic>>> _latestProductsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _fetchRecommendProducts();
//     _fetchLatestProducts();
//   }

//   void _fetchRecommendProducts() {
//     setState(() {
//       _recommendProductsFuture = fetchRecommendProducts();
//     });
//   }

//   void _fetchLatestProducts() {
//     setState(() {
//       _latestProductsFuture = fetchLatestProducts();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productProvider = Provider.of<ProductProvider>(context);
//     return Column(
//       children: [
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.3,
//           child: Column(
//             children: [
//               SectionHeader(title: 'Recommend Product'),
//               Expanded(
//                 child: FutureBuilder<List<Map<String, dynamic>>>(
//                   future: _recommendProductsFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return SingleChildScrollView(child: _buildShimmer());
//                     } else if (snapshot.hasError || snapshot.data == null) {
//                       return _buildErrorSection();
//                     } else {
//                       return SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             for (var product in snapshot.data!)
//                               ProductCard(
//                                 key: ValueKey(product['id']),
//                                 product: product,
//                                 onAdd: () {
//                                   productProvider.increaseQuantity(
//                                       product['id'],
//                                       product['name'],
//                                       product['price'].toString(),
//                                       "recommend");
//                                   _incrementQuantity(product['name'],
//                                       product['id'], "recommend");
//                                 },
//                                 onRemove: () {
//                                   productProvider.decreaseQuantity(
//                                       product['id'],
//                                       product['name'],
//                                       product['price'].toString(),
//                                       "recommend");
//                                   _decrementQuantity(product['name'],
//                                       product['id'], "recommend");
//                                 },
//                               ),
//                           ],
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Column(
//             children: [
//               SectionHeader(title: 'Latest Products'),
//               Expanded(
//                 child: FutureBuilder<List<Map<String, dynamic>>>(
//                   future: _latestProductsFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return SingleChildScrollView(
//                           child: Column(
//                         children: [
//                           _buildShimmer(),
//                           _buildShimmer(),
//                         ],
//                       ));
//                     } else if (snapshot.hasError || snapshot.data == null) {
//                       return const SizedBox.shrink();
//                     } else {
//                       return SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             for (var product in snapshot.data!)
//                               ProductCard(
//                                 key: ValueKey(product['id']),
//                                 product: product,
//                                 onAdd: () {
//                                   productProvider.increaseQuantity(
//                                       product['id'],
//                                       product['name'],
//                                       product['price'].toString(),
//                                       "latest");
//                                   _incrementQuantity(
//                                       product['name'], product['id'], "latest");
//                                 },
//                                 onRemove: () {
//                                   productProvider.decreaseQuantity(
//                                       product['id'],
//                                       product['name'],
//                                       product['price'].toString(),
//                                       "latest");
//                                   _decrementQuantity(
//                                       product['name'], product['id'], "latest");
//                                 },
//                               ),
//                           ],
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildShimmer() {
//     double width = MediaQuery.sizeOf(context).width;
//     return Column(
//       children: List.generate(
//         4,
//         (index) => Shimmer(
//           gradient: _shimmerGradient,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.fromLTRB(16, 8, 8, 8),
//                     height: 78,
//                     width: 78,
//                     decoration: BoxDecoration(
//                       color: Color(0xFFE6E0E9),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         margin: const EdgeInsets.all(8),
//                         height: 20,
//                         width: width / 2,
//                         decoration: BoxDecoration(
//                           color: Color(0xFFE6E0E9),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.all(8),
//                         height: 20,
//                         width: width / 3,
//                         decoration: BoxDecoration(
//                           color: Color(0xFFE6E0E9),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorSection() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const SizedBox(height: 16),
//         const Text(
//           "Something went wrong",
//           style: TextStyle(fontSize: 16, color: MainColors.errorColor),
//         ),
//         const SizedBox(height: 8),
//         FilledButton(
//           onPressed: _fetchRecommendProducts,
//           child: const Text("Refresh"),
//         ),
//       ],
//     );
//   }

//   // Increment the quantity for a specific product
//   void _incrementQuantity(String name, int id, String productType) {
//     setState(() {
//       final productsFuture = productType == "latest"
//           ? _latestProductsFuture
//           : _recommendProductsFuture;

//       productsFuture.then((products) {
//         final product = products.firstWhere((p) => p['id'] == id);
//         product['quantity']++;
//       });
//     });
//   }

// // Decrease the quantity for a specific product
//   void _decrementQuantity(String name, int id, String productType) {
//     setState(() {
//       final productsFuture = productType == "latest"
//           ? _latestProductsFuture
//           : _recommendProductsFuture;

//       productsFuture.then((products) {
//         final product = products.firstWhere((p) => p['id'] == id);
//         product['quantity']--;
//       });
//     });
//   }
// }
