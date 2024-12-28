import 'package:flutter/material.dart';
import 'package:flutter_application/shared/cart_notifier.dart'; // Import CartNotifier

class ProductProvider with ChangeNotifier {
  List<Map<String, dynamic>> addedProduct = [];

  /// Increases the quantity of a product in the cart.
  void increaseQuantity(int productId, String productName, String productPrice,
      String productType) {
    // Find the index of the product in the addedProduct list
    final existingProductIndex = addedProduct.indexWhere((product) =>
        product['productId'] == productId &&
        product['productName'] == productName &&
        product['productPrice'] == productPrice &&
        product['productType'] == productType);

    if (existingProductIndex != -1) {
      // Product exists, increase the quantity
      addedProduct[existingProductIndex]['quantity']++;
    } else {
      // Product not found, add a new item to the list
      addedProduct.add({
        'productId': productId,
        'productName': productName,
        'productPrice': productPrice,
        'productType': productType,
        'quantity': 1,
      });
    }

    // Increment the cart item count
    cartItemCount.value++;

    // Notify listeners about changes
    notifyListeners();
  }

  /// Decrease the quantity of a product in the cart
  void decreaseQuantity(int productId, String productName, String productPrice,
      String productType) {
    // Find the product in the list
    final existingIndex = addedProduct.indexWhere((product) =>
        product['productId'] == productId &&
        product['productName'] == productName &&
        product['productPrice'] == productPrice &&
        product['productType'] == productType);

    if (existingIndex != -1) {
      // Product exists, decrease the quantity
      if (addedProduct[existingIndex]['quantity'] > 1) {
        // Decrease the quantity if it is more than 1
        addedProduct[existingIndex]['quantity']--;
      } else {
        // Quantity is 1, remove the product from the list
        addedProduct.removeAt(existingIndex);
      }

      // Decrement the cart item count
      if (cartItemCount.value > 0) {
        cartItemCount.value--;
      }

      // Notify listeners about changes
      notifyListeners();
    }
  }

  /// Clears all added products from the cart.
  void clearCart() {
    addedProduct.clear();
    cartItemCount.value = 0; // Reset the cart item count
    notifyListeners(); // Notify listeners about changes
  }
}
