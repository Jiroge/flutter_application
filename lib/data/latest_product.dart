// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import 'package:flutter_application/config.dart';

// Future<List<Map<String, dynamic>>> fetchLatestProducts() async {
//   const String url = '$apiUrl/products?limit=20';

//   try {
//     await Future.delayed(const Duration(seconds: 2));
//     // Make the HTTP GET request
//     final response = await http.get(Uri.parse(url));

//     // Check if the response status code is successful
//     if (response.statusCode == 200) {
//       // Decode the JSON response into a Dart map
//       final Map<String, dynamic> jsonData = json.decode(response.body);

//       // Extract the items list
//       final List<dynamic> items = jsonData['items'] ?? [];

//       // Map the items list to a list of Map<String, dynamic>
//       return items.map<Map<String, dynamic>>((item) {
//         return {
//           'id': item['id'],
//           'name': item['name'],
//           'price': item['price'],
//           'quantity': 0, // Default quantity is 0
//         };
//       }).toList();
//     } else {
//       throw Exception(
//           'Failed to fetch products. Status code: ${response.statusCode}');
//     }
//   } catch (error) {
//     // Handle any errors during the HTTP request or JSON decoding
//     throw Exception('An error occurred: $error');
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application/config.dart';

Future<Map<String, dynamic>> fetchLatestProducts({String? cursor}) async {
  final String url = cursor != null 
    ? '$apiUrl/products?limit=20&cursor=$cursor'
    : '$apiUrl/products?limit=20';

  try {
    await Future.delayed(const Duration(seconds: 2));
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> items = jsonData['items'] ?? [];
      final String? nextCursor = jsonData['nextCursor'];

      return {
        'items': items.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'price': item['price'],
            'quantity': 0,
          };
        }).toList(),
        'nextCursor': nextCursor,
      };
    } else {
      throw Exception('Failed to fetch products. Status code: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('An error occurred: $error');
  }
}