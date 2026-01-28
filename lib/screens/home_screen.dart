import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player/video_player.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loaders.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'category_screen.dart';
import 'about_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    // Start fetching (mostly just an extra check, Splash should have started it)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchFeaturedProducts();
    });
    _videoController = VideoPlayerController.asset('Video/Hero_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setVolume(0); // Mute the video
        _videoController.setLooping(false); // Stop looping
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildPremiumDrawer(context),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          'NOVA WEAR',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
          ),
          _buildCartIcon(context),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: () async {
          await context.read<ProductProvider>().fetchFeaturedProducts(forceRefresh: true);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              _buildCategoryScroll(),
              _buildProductSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 28),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
            ),
            if (cart.itemCount > 0)
              Positioned(
                right: 8,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${cart.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return FadeIn(
      duration: const Duration(seconds: 1),
      child: Stack(
        children: [
          SizedBox(
            height: 550,
            width: double.infinity,
            child: _videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          Container(
            height: 550,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 60,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInLeft(
                  delay: const Duration(milliseconds: 500),
                  child: const Text(
                    'WE STYLE YOU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'all'))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text('SHOP NOW', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScroll() {
    final categories = [
      {'title': 'KNOT TOPS', 'img': 'Video/Knot_top.jpeg', 'id': 'knot_tops'},
      {'title': 'CROP TOPS', 'img': 'Video/Crop_Top.png', 'id': 'crop_tops'},
      {'title': 'T-SHIRTS', 'img': 'Video/T_shirt.png', 'id': 'tshirts'},
      {'title': 'CARGO PANTS', 'img': 'Video/Cargo_Pants.png', 'id': 'cargo_pants'},
      {'title': 'OUT WEAR', 'img': 'Video/Out_Wear.jpeg', 'id': 'outerwear'},
      {'title': 'ACCESSORIES', 'img': 'Video/Accesory.jpeg', 'id': 'accessories'},
      {'title': 'DRESSES', 'img': 'https://images.unsplash.com/photo-1612336307429-8a898d10e223?auto=format&fit=crop&w=300&q=80', 'id': 'dresses'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text('EXPLORE CATEGORIES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _categoryItem(categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryItem(Map<String, String> cat) {
    final bool isAsset = cat['img']!.startsWith('Video/');
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryScreen(category: cat['id']!))),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: Stack(
          children: [
            isAsset
                ? Image.asset(
                    cat['img']!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: cat['img']!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
            Container(color: Colors.black.withOpacity(0.1)),
            Center(
              child: Text(
                cat['title']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NEW ARRIVALS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
          const SizedBox(height: 25),
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.featuredProducts.isEmpty) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => const ProductShimmer(),
                );
              }
              
              if (provider.featuredProducts.isEmpty) {
                return const Center(child: Text('NO PRODUCTS AVAILABLE', style: TextStyle(fontWeight: FontWeight.bold)));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: provider.featuredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: provider.featuredProducts[index], index: index);
                },
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildPremiumDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(40),
            decoration: const BoxDecoration(color: Colors.black),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('NOVA WEAR', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  SizedBox(height: 5),
                  Text('WE STYLE YOU', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _drawerTile(Icons.home_outlined, 'HOME', () => Navigator.pop(context)),
                _drawerTile(Icons.shopping_bag_outlined, 'ALL PRODUCTS', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'all')));
                }),
                const Divider(height: 40),
                const Text('CATEGORIES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2, color: Colors.grey)),
                const SizedBox(height: 20),
                _drawerTile(null, 'KNOT TOPS', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'knot_tops')));
                }),
                _drawerTile(null, 'CROP TOPS', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'crop_tops')));
                }),
                _drawerTile(null, 'T-SHIRTS', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'tshirts')));
                }),
                _drawerTile(null, 'CARGO PANTS', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'cargo_pants')));
                }),
                _drawerTile(null, 'OUT WEAR', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'outerwear')));
                }),
                _drawerTile(null, 'ACCESSORIES', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'accessories')));
                }),
                _drawerTile(null, 'DRESSES', () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen(category: 'dresses')));
                }),
                const Divider(height: 40),
                _drawerTile(Icons.info_outline, 'ABOUT US', () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                }),
                _drawerTile(Icons.contact_support_outlined, 'CONTACT', () {
                   Navigator.pop(context);
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactScreen()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData? icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon != null ? Icon(icon, color: Colors.black) : null,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
      onTap: onTap,
    );
  }
}
