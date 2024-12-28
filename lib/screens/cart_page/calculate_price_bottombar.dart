import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application/config.dart';

class CalculatePriceBottombar extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback checkoutSuccess;

  const CalculatePriceBottombar(
      {super.key, required this.cartItems, required this.checkoutSuccess});

  @override
  State<CalculatePriceBottombar> createState() =>
      _CalculatePriceBottombarState();
}

class _CalculatePriceBottombarState extends State<CalculatePriceBottombar> {
  final NumberFormat currencyFormatter = NumberFormat('#,##0.00', 'en_US');

  Map<String, String> calculateCartTotals() {
    double totalOriginalPrice = 0;
    double totalDiscountPrice = 0;
    double totalPriceAfterDiscount = 0;

    for (var item in widget.cartItems) {
      int quantity = int.parse(item['quantity'].toString());
      double price = double.parse(item['productPrice'].toString());

      int pairCount = quantity ~/ 2;
      int remainingUnits = quantity % 2;

      // Calculate for pairs
      double pairPrice = pairCount * (price * 2);
      double pairDiscount = pairPrice * 0.05;
      double discountedPairPrice = pairPrice - pairDiscount;

      // Calculate for remaining units
      double remainingPrice = remainingUnits * price;

      // Total for this product
      totalOriginalPrice += (pairPrice + remainingPrice);
      totalDiscountPrice += pairDiscount;
      totalPriceAfterDiscount += (discountedPairPrice + remainingPrice);
    }

    return {
      'totalOriginalPrice': currencyFormatter.format(totalOriginalPrice),
      'totalDiscountPrice': currencyFormatter.format(totalDiscountPrice),
      'totalPriceAfterDiscount':
          currencyFormatter.format(totalPriceAfterDiscount),
    };
  }

  @override
  Widget build(BuildContext context) {
    final summary = calculateCartTotals();
    

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MainColors.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: const TextStyle(
                    fontSize: 18, color: MainColors.primaryColor),
              ),
              Text(
                "${summary['totalOriginalPrice']}",
                style: const TextStyle(
                    fontSize: 18, color: MainColors.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Promotion discount",
                style: const TextStyle(
                    fontSize: 18, color: MainColors.primaryColor),
              ),
              Text(
                "-${summary['totalDiscountPrice']}",
                style: const TextStyle(fontSize: 18, color: MainColors.errorColor,),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${summary['totalPriceAfterDiscount']}",
                style: const TextStyle(
                    fontSize: 24, color: MainColors.primaryColor),
              ),
              FilledButton(onPressed: widget.checkoutSuccess, child: Text("Checkout"))
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
