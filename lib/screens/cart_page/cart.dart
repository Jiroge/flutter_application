import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import 'package:flutter_application/screens/cart_page/calculate_price_bottombar.dart';
import 'package:flutter_application/screens/cart_page/product_card.dart';
import 'package:flutter_application/shared/product_provider.dart';
import 'package:flutter_application/config.dart';

class CartPage extends StatefulWidget {
  final VoidCallback onBackToHome;

  const CartPage({super.key, required this.onBackToHome});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  bool _checkoutSuccess = false;

  Future<void> checkout() async {
    try {
      final productIds = context
          .read<ProductProvider>()
          .addedProduct
          .map((item) => item['productId'])
          .toList();

      final requestBody = {
        'products': productIds,
      };

      final response = await http.post(
        Uri.parse('$apiUrl/orders/checkout'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 204) {
        if (mounted) {
          setState(() {
            _checkoutSuccess = true;
          });
          final productProvider = context.read<ProductProvider>();
          productProvider.clearCart();
        }
      } else if (response.statusCode == 500) {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        if (mounted) {
          final productProvider = context.read<ProductProvider>();
          productProvider.clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: MainColors.errorColor,
            ),
          );
        }
      } else if (response.statusCode == 502) {
        final errorMessage =
            response.body.isNotEmpty ? response.body : 'Bad Gateway';
        if (mounted) {
          final productProvider = context.read<ProductProvider>();
          productProvider.clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: MainColors.errorColor,
            ),
          );
        }
      } else {
        if (mounted) {
          final productProvider = context.read<ProductProvider>();
          productProvider.clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected error: ${response.statusCode}'),
              backgroundColor: MainColors.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final productProvider = context.read<ProductProvider>();
        productProvider.clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: MainColors.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onBackToHome,
                      ),
                      const Text(
                        'Cart',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    if (_checkoutSuccess) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: height / 3),
                            const Text(
                              'Success!',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            const Text(
                              'Thank you for shopping with us!',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {
                                widget.onBackToHome();
                              },
                              child: const Text("Shop Again"),
                            ),
                          ],
                        ),
                      );
                    } else if (productProvider.addedProduct.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: height / 3),
                            const Text(
                              'Empty Cart',
                              style: TextStyle(fontSize: 18),
                            ),
                            FilledButton(
                              onPressed: widget.onBackToHome,
                              child: const Text("Go to shopping"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Column(
                        children: productProvider.addedProduct.map((product) {
                          return Dismissible(
                            key: ValueKey(
                                "${product['productId']}-${product['productType']}-${product['productName']}-${product['productPrice']}),}"),
                            confirmDismiss: (direction) async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: MainColors.errorColor,
                                  content: const Text(
                                    'Something went wrong',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              );
                              return false;
                            },
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: MainColors.errorColor,
                              padding: const EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            child: ProductCard(
                              product: product,
                              onAdd: () {
                                productProvider.increaseQuantity(
                                  product['productId'],
                                  product['productName'],
                                  product['productPrice'].toString(),
                                  product['productType'],
                                );
                              },
                              onRemove: () {
                                productProvider.decreaseQuantity(
                                  product['productId'],
                                  product['productName'],
                                  product['productPrice'].toString(),
                                  product['productType'],
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                SizedBox(height: height / 5),
              ],
            ),
          ),
          SizedBox(height: height),
          Consumer<ProductProvider>(builder: (context, productProvider, child) {
            if (productProvider.addedProduct.isNotEmpty && !_checkoutSuccess) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CalculatePriceBottombar(
                  cartItems: productProvider.addedProduct,
                  checkoutSuccess: () {
                    checkout();
                  },
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          })
        ],
      ),
    );
  }
}
