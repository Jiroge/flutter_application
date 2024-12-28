import 'package:flutter/material.dart';
import 'package:flutter_application/screens/cart_page/cart.dart';
import 'package:flutter_application/screens/shopping_page/shopping.dart';

List<Widget> bottombarScreenOptions({required VoidCallback onBackToHome}) {
  return [
    ShoppingPage(),
    CartPage(onBackToHome: onBackToHome),
  ];
}
