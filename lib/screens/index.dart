import 'package:flutter/material.dart';
import 'package:flutter_application/screens/bottombar.dart';

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomBar(),
      debugShowCheckedModeBanner: false,
    );
  }
}
