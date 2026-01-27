import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:photo_view/photo_view.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.contains('M') ? 'M' : widget.product.sizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.product.image.startsWith('http') 
        ? widget.product.image 
        : '${ApiService.baseUrl}${widget.product.image}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Image View
            SizedBox(
              height: 500,
              width: double.infinity,
              child: Hero(
                tag: 'product-${widget.product.id}',
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(imageUrl),
                  backgroundDecoration: const BoxDecoration(color: Colors.white),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product.category.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'KES ${widget.product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      widget.product.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'SELECT SIZE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: widget.product.sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = size),
                        child: Container(
                          width: 65,
                          height: 55,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'PRODUCT INFO',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'The NOVA WEAR ${widget.product.name} provides contemporary style mixed with premium comfort. This ${widget.product.category} is crafted from high-quality materials designed for longevity and everyday luxury.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.8,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 120), 
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(25),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: _selectedSize == null 
              ? null 
              : () {
                  context.read<CartProvider>().addItem(widget.product, _selectedSize!);
                  _showSuccessSnackbar();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 65),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
          ),
          child: const Text(
            'ADD TO BAG',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar() {
    // Create a snackbar that auto-dismisses after 2 seconds and is swipeable
    final snackBar = SnackBar(
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2), // Auto-dismiss after 2 seconds
      content: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 10),
          Text('ADDED TO YOUR BAG', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
      action: SnackBarAction(
        label: 'VIEW BAG',
        textColor: Colors.white,
        onPressed: () {
          // Navigate to cart and dismiss snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
        },
      ),
    );

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}