import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_application/config.dart';

Future<List<Map<String, dynamic>>> fetchRecommendProducts() async {
  // Define the URL
  const String url = '$apiUrl/recommended-products';

  try {
    await Future.delayed(const Duration(seconds: 2));
    // Make the HTTP GET request
    final response = await http.get(Uri.parse(url));

    // Check if the response status code is successful
    if (response.statusCode == 200) {
      // Decode the JSON response into a Dart list
      final List<dynamic> jsonData = json.decode(response.body);

      // Map the JSON data to a list of Map<String, dynamic>
      return jsonData.map<Map<String, dynamic>>((product) {
        return {
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'quantity': 0, // Default quantity is 0
        };
      }).toList();
    } else {
      throw Exception(
          'Failed to fetch products. Status code: ${response.statusCode}');
    }
  } catch (error) {
    // Handle any errors during the HTTP request or JSON decoding
    throw Exception('An error occurred: $error');
  }
}
