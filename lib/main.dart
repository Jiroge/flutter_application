import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/screens/index.dart';
import 'shared/product_provider.dart';

// Shared ValueNotifier
final ValueNotifier<int> cartItemCount = ValueNotifier<int>(0);

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const ShoppingApp(),
    ),
  );
}
