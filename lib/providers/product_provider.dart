import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _featuredProducts = [];
  List<Product> _allProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const String _featuredCacheKey = 'cached_featured_products';
  static const String _allCacheKey = 'cached_all_products';

  ProductProvider() {
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Featured
      final String? featuredData = prefs.getString(_featuredCacheKey);
      if (featuredData != null) {
        final List<dynamic> decoded = json.decode(featuredData);
        _featuredProducts = decoded.map((item) => Product.fromJson(item)).toList();
      }

      // Load All
      final String? allData = prefs.getString(_allCacheKey);
      if (allData != null) {
        final List<dynamic> decoded = json.decode(allData);
        _allProducts = decoded.map((item) => Product.fromJson(item)).toList();
      }

      notifyListeners();
    } catch (e) {
      print('Error loading products from cache: $e');
    }
  }

  Future<void> _saveToCache(String key, List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(products.map((p) => p.toJson()).toList());
      await prefs.setString(key, encodedData);
    } catch (e) {
      print('Error saving products to cache ($key): $e');
    }
  }

  Future<void> fetchFeaturedProducts({bool forceRefresh = false}) async {
    if (_featuredProducts.isEmpty || forceRefresh) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final products = await _apiService.fetchFeaturedProducts();
      if (products.isNotEmpty) {
        _featuredProducts = products;
        _saveToCache(_featuredCacheKey, products);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllProducts({bool forceRefresh = false}) async {
    if (_allProducts.isEmpty || forceRefresh) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final products = await _apiService.fetchProductsByCategory('all');
      if (products.isNotEmpty) {
        _allProducts = products;
        _saveToCache(_allCacheKey, products);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
