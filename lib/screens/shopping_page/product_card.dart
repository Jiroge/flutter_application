import 'package:flutter/material.dart';
import 'package:flutter_application/config.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: MainColors.backgroundColor,
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child: Row(
              children: [
                Image.network(
                  "https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png",
                  width: 78,
                  height: 78,
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MainColors.textColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text(
                          "${product['price'].toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 18, color: MainColors.textColor),
                        ),
                        Text(
                          " / unit",
                          style: const TextStyle(
                              fontSize: 14, color: MainColors.textColor),
                        ),
                      ])
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: product['quantity'] > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _roundedIconButton(
                        icon: Icons.remove,
                        color: MainColors.primaryColor,
                        onPressed: onRemove,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product['quantity'].toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 2),
                      _roundedIconButton(
                        icon: Icons.add,
                        color: MainColors.primaryColor,
                        onPressed: onAdd,
                      ),
                    ],
                  )
                : FilledButton(
                    onPressed: onAdd,
                    child: const Text(
                      "Add to cart",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _roundedIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 24.0),
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}
