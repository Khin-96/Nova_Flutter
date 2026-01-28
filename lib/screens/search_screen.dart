import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loaders.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product>? _results;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllProducts();
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _results = null);
      return;
    }

    final allProducts = context.read<ProductProvider>().allProducts;
    if (allProducts.isEmpty) return;

    final filtered = allProducts.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) || 
      p.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    setState(() => _results = filtered);
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
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allProducts.isEmpty) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const ProductShimmer(),
            );
          }

          if (_results == null) {
            return Center(
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
            );
          }

          if (_results!.isEmpty) {
            return const Center(
              child: Text(
                'NO PRODUCTS FOUND',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            );
          }

          return GridView.builder(
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
          );
        },
      ),
    );
  }
}
