import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loaders.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Product>? _results;
  bool _isLoading = false;

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = null;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate/Actual search logic
    try {
      final products = await _apiService.fetchProductsByCategory('all');
      final filtered = products.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase()) || 
        p.category.toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      setState(() {
        _results = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'SEARCH PRODUCTS...',
            border: InputBorder.none,
            hintStyle: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _isLoading 
        ? GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const ProductShimmer(),
          )
        : _results == null
          ? Center(
              child: FadeInDown(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'START TYPING TO SEARCH',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _results!.isEmpty
            ? const Center(
                child: Text(
                  'NO PRODUCTS FOUND',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: _results!.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: _results![index], index: index);
                },
              ),
    );
  }
}
