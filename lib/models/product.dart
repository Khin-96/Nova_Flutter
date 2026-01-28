class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final List<String> sizes;
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.sizes,
    required this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      sizes: List<String>.from(json['sizes'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'sizes': sizes,
      'tags': tags,
    };
  }
}
