import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  void _handleCheckout(CartProvider cart) async {
    if (_phoneController.text.isEmpty || !_phoneController.text.startsWith('254')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid M-Pesa number (e.g., 2547...)')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await _apiService.initiateMpesaPayment(
        _phoneController.text,
        cart.total,
      );

      if (success) {
        // Create Order
        final orderData = {
          'items': cart.items.map((i) => i.toJson()).toList(),
          'phone': _phoneController.text,
          'total': cart.total,
          'location': cart.deliveryLocation,
          'status': 'pending',
        };
        await _apiService.createOrder(orderData);
        
        cart.clear();
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initiate payment. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('ORDER PLACED', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Please check your phone for the M-Pesa pin prompt to complete payment.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close cart
            },
            child: const Text('CONTINUE SHOPPING', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('YOUR BAG', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(child: const Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey)),
                  const SizedBox(height: 20),
                  const Text('YOUR BAG IS EMPTY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text('START SHOPPING', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final String imageUrl = item.image.startsWith('http') 
                          ? item.image 
                          : '${ApiService.baseUrl}${item.image}';
                      
                      return FadeInLeft(
                        delay: Duration(milliseconds: 100 * index),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 25.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[100],
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                    const SizedBox(height: 5),
                                    Text('SIZE: ${item.size}', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            _qtyBtn(Icons.remove, () => cart.updateQuantity(item.id, item.size, false)),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            _qtyBtn(Icons.add, () => cart.updateQuantity(item.id, item.size, true)),
                                          ],
                                        ),
                                        Text('KES ${(item.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => cart.removeItem(item.id, item.size),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _checkoutPanel(cart),
              ],
            ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _checkoutPanel(CartProvider cart) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10)),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Delivery Location
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('DELIVERY LOCATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  DropdownButton<String>(
                    value: cart.deliveryLocation,
                    underline: const SizedBox(),
                    onChanged: (val) => cart.setDeliveryLocation(val!),
                    items: const [
                      DropdownMenuItem(value: 'mombasa', child: Text('MOMBASA')),
                      DropdownMenuItem(value: 'kilifi', child: Text('KILIFI')),
                      DropdownMenuItem(value: 'other', child: Text('OTHER')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Phone input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'M-PESA PHONE (2547...)',
                  hintStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
                ),
              ),
              const SizedBox(height: 25),
              _summaryRow('SUBTOTAL', 'KES ${cart.subtotal.toStringAsFixed(0)}'),
              const SizedBox(height: 10),
              _summaryRow('DELIVERY', 'KES ${cart.deliveryFee.toStringAsFixed(0)}'),
              const Divider(height: 30, color: Colors.black),
              _summaryRow('TOTAL', 'KES ${cart.total.toStringAsFixed(0)}', isTotal: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isProcessing ? null : () => _handleCheckout(cart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('PROCESS PAYMENT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600, fontSize: isTotal ? 18 : 14)),
        Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600, fontSize: isTotal ? 18 : 14)),
      ],
    );
  }
}
