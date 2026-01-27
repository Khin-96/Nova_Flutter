import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('OUR STORY'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FadeIn(
              child: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&w=1470&q=80',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    child: const Text(
                      'THE NOVA\nVISION',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Nova Wear was founded in 2025 with a simple mission: to provide high-quality, contemporary clothing for the modern lifestyle. What started as a small boutique in Mombasa has grown into a beloved brand across Kenya.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.8,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'Our founder, Kinga, started Nova Wear after noticing a gap in the market for stylish, locally-available clothing that combines comfort with cutting-edge design. Each piece in our collection is carefully selected to ensure quality and style.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        height: 1.8,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Divider(),
                  const SizedBox(height: 30),
                  const Text(
                    'LOCATIONS:',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  const SizedBox(height: 15),
                  const Text('MTWAPA • KILIFI • MOMBASA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
