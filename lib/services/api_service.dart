import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://novawear.onrender.com';

  /// Triggers a light request to the backend to wake it up from sleep (useful for Render/Heroku free tiers)
  Future<void> warmUpServer() async {
    try {
      // Just hit the root or a lightweight endpoint
      await http.get(Uri.parse('$baseUrl/')).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignore errors during warmup
    }
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products/featured'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load featured products');
      }
    } catch (e) {
      print('Error fetching featured products: $e');
      return []; // Return empty list on failure for now
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final String endpoint = category == 'all' 
          ? '/api/products' 
          : '/api/products?category=${Uri.encodeComponent(category)}';
      
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  Future<bool> initiateMpesaPayment(String phone, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mpesa/stkpush'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'amount': amount,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error initiating M-Pesa payment: $e');
      return false;
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }
}
