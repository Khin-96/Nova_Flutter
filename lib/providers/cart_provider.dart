import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String _deliveryLocation = 'mombasa';
  static const double DELIVERY_FEE = 450.0;

  List<CartItem> get items => [..._items];
  String get deliveryLocation => _deliveryLocation;

  CartProvider() {
    loadCart();
  }

  double get subtotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get deliveryFee {
    return _deliveryLocation == 'other' ? DELIVERY_FEE : 0.0;
  }

  double get total => subtotal + deliveryFee;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(Product product, String size) {
    final existingIndex = _items.indexWhere(
      (item) => item.id == product.id && item.size == size,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          image: product.image,
          size: size,
        ),
      );
    }
    saveCart();
    notifyListeners();
  }

  void removeItem(String id, String size) {
    _items.removeWhere((item) => item.id == id && item.size == size);
    saveCart();
    notifyListeners();
  }

  void updateQuantity(String id, String size, bool increase) {
    final index = _items.indexWhere((item) => item.id == id && item.size == size);
    if (index >= 0) {
      if (increase) {
        _items[index].quantity += 1;
      } else {
        _items[index].quantity -= 1;
        if (_items[index].quantity <= 0) {
          _items.removeAt(index);
        }
      }
      saveCart();
      notifyListeners();
    }
  }

  void setDeliveryLocation(String location) {
    _deliveryLocation = location;
    notifyListeners();
  }

  void clear() {
    _items = [];
    saveCart();
    notifyListeners();
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = json.encode(_items.map((i) => i.toJson()).toList());
    prefs.setString('cart', cartData);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('cart')) return;
    final List<dynamic> cartData = json.decode(prefs.getString('cart')!);
    _items = cartData.map((item) => CartItem.fromJson(item)).toList();
    notifyListeners();
  }
}
