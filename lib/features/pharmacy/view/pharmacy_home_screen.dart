import 'dart:async';
import 'dart:convert';
import 'package:door/features/components/custom_appbar.dart';
import 'package:door/main.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:door/services/pharmacy_product_service.dart';
import 'package:door/services/models/pharmacy_models.dart';
import 'package:door/services/api_client.dart';
import 'package:door/product_detail_page.dart';
import 'package:door/cart_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PharmacyHomeScreen extends StatefulWidget {
  const PharmacyHomeScreen({super.key});

  @override
  State<PharmacyHomeScreen> createState() => _PharmacyHomeScreenState();
}

class _PharmacyHomeScreenState extends State<PharmacyHomeScreen>
    with SingleTickerProviderStateMixin {
  static const _kCartKey = 'pharmacy_cart_v1';
  final PharmacyProductService _productService = PharmacyProductService();
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  late Future<ProductsResponse> _productsFuture;
  List<PharmacyProduct> _allProducts = const [];
  final Map<String, int> _cart = {}; // productId -> quantity
  Map<String, PharmacyProduct> _productsById = {};
  late final AnimationController _cartAttentionController;
  late final Animation<double> _cartScaleAnimation;
  Timer? _cartHintTimer;
  bool _showCartHint = false;
  String _cartHintMessage = 'Added to cart. Tap the bag to checkout.';

  int get _cartItemsCount =>
      _cart.values.fold<int>(0, (sum, q) => sum + (q > 0 ? q : 0));

  @override
  void initState() {
    super.initState();
    _cartAttentionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _cartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.16).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.16, end: 0.96).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.96, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 35,
      ),
    ]).animate(_cartAttentionController);
    _productsFuture = _fetchProducts();
    _loadCartFromLocal();
  }

  @override
  void dispose() {
    _cartHintTimer?.cancel();
    _cartAttentionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCartKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, dynamic> m = json.decode(raw);
      setState(() {
        _cart.clear();
        _cart.addAll(
            m.map((k, v) => MapEntry(k, (v as num).toInt())));
      });
    } catch (_) {
      // ignore corrupt data
    }
  }

  Future<void> _saveCartToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _cart.map((k, v) => MapEntry(k, v));
    await prefs.setString(_kCartKey, json.encode(map));
  }

  Future<void> _clearCartLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCartKey);
  }

  Future<ProductsResponse> _fetchProducts({
    String? search,
    String? category,
  }) async {
    final response = await _productService.getProducts(
      search: search,
      category: category,
      page: 1,
      limit: 50,
    );

    if (response.success && response.data != null) {
      setState(() {
        _allProducts = response.data!.items;
        _productsById = {
          for (final p in response.data!.items) p.id: p
        };
      });
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to load products');
    }
  }

  void _addToCart(PharmacyProduct product, {int qty = 1}) {
    if (qty <= 0) return;
    setState(() {
      _cart.update(product.id, (q) => q + qty, ifAbsent: () => qty);
    });
    _saveCartToLocal();
    _playCartFeedback(product, qty: qty);
  }

  void _playCartFeedback(PharmacyProduct product, {int qty = 1}) {
    _cartAttentionController.forward(from: 0);
    _cartHintTimer?.cancel();
    setState(() {
      _showCartHint = true;
      _cartHintMessage =
          qty > 1
              ? '$qty items of ${product.name} added. Tap the bag to checkout.'
              : '${product.name} added to cart. Tap the bag to checkout.';
    });
    _cartHintTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _showCartHint = false;
      });
    });
  }

  Future<void> _openCart() async {
    if (_productsById.isEmpty) return;
    final updated = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(
          productsById: _productsById,
          quantities: _cart,
          onCheckout: () async {
            setState(() => _cart.clear());
            await _clearCartLocal();
          },
        ),
      ),
    );
    if (updated != null) {
      setState(() {
        _cart.clear();
        _cart.addAll(updated);
      });
      _saveCartToLocal();
    }
  }

  void _handleSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (_allProducts.isEmpty) {
      setState(() {
        _productsFuture = _fetchProducts(search: query.isEmpty ? null : query);
      });
      return;
    }

    final filtered = normalized.isEmpty
        ? _allProducts
        : _allProducts.where((product) {
            final haystack = [
              product.name,
              product.category ?? '',
              product.brand ?? '',
              product.sku ?? '',
              product.strength ?? '',
              product.description ?? '',
              product.dosageForm ?? '',
              ...(product.tags ?? const <String>[]),
            ].join(' ').toLowerCase();
            return haystack.contains(normalized);
          }).toList();

    setState(() {
      _productsFuture = Future.value(
        ProductsResponse(
          items: filtered,
          pagination: snapPagination(filtered.length),
        ),
      );
    });
  }

  PaginationInfo snapPagination(int total) => PaginationInfo(
        total: total,
        page: 1,
        limit: total == 0 ? 1 : total,
        totalPages: total == 0 ? 0 : 1,
      );

  String _getImageUrl(PharmacyProduct product) {
    if (product.imageUrl.isNotEmpty) {
      final imageUrl = product.imageUrl;
      if (imageUrl.startsWith('http')) {
        return imageUrl;
      } else if (imageUrl.startsWith('/')) {
        return '${_apiClient.baseUrl.replaceAll('/api', '')}$imageUrl';
      }
      return imageUrl;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Pharmacy",
        actions: [
          GestureDetector(
            onTap: _openCart,
            child: ScaleTransition(
              scale: _cartScaleAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _showCartHint
                              ? const Color(0xFFE7F0FF)
                              : const Color(0xFFF2F3F7),
                      border:
                          _showCartHint
                              ? Border.all(
                                color: const Color(0xFF2F5DFB).withOpacity(0.25),
                              )
                              : null,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 20,
                      color:
                          _showCartHint
                              ? const Color(0xFF2F5DFB)
                              : AppColors.grey,
                    ),
                  ),
                  if (_cartItemsCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$_cartItemsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSlide(
              offset: _showCartHint ? Offset.zero : const Offset(0, -0.2),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _showCartHint ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: _showCartHint
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _openCart,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 290),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF4FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFCFE0FF),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: Color(0xFF2F5DFB),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _cartHintMessage,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF21407F),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Color(0xFF2F5DFB),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(
                      controller: _searchController,
                      onChanged: _handleSearch,
                    ),
                    const SizedBox(height: 16),
                    PharmacyBanner(
                      imagePath:
                          "https://c8.alamy.com/comp/2RE32E3/online-pharmacy-banner-vector-concept-2RE32E3.jpg",
                    ),
                    const SizedBox(height: 30),
                    FutureBuilder<ProductsResponse>(
                      future: _productsFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (snap.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'Failed to load products: ${snap.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _productsFuture = _fetchProducts();
                                    });
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                        final items = snap.data?.items ?? [];
                        if (items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _searchController.text.trim().isEmpty
                                  ? 'No products available.'
                                  : 'No products found for "${_searchController.text.trim()}".',
                            ),
                          );
                        }

                        final isSearching =
                            _searchController.text.trim().isNotEmpty;
                        final half = (items.length / 2).ceil();
                        final popular = items.take(half).toList();
                        final sale = items.skip(half).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isSearching) ...[
                              const _SectionHeader(title: 'Search Results'),
                              const SizedBox(height: 12),
                              _ProductHorizontalList(
                                products: items,
                                onAdd: (p) => _addToCart(p),
                                onTap: (p) async {
                                  final result = await Navigator.push<int>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailPage(product: p),
                                    ),
                                  );
                                  if (result != null && result > 0) {
                                    _addToCart(p, qty: result);
                                  }
                                },
                                getImageUrl: _getImageUrl,
                                showOldPrice: true,
                              ),
                            ] else ...[
                              const _SectionHeader(title: 'Popular Product'),
                              const SizedBox(height: 12),
                              _ProductHorizontalList(
                                products: popular,
                                onAdd: (p) => _addToCart(p),
                                onTap: (p) async {
                                  final result = await Navigator.push<int>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailPage(product: p),
                                    ),
                                  );
                                  if (result != null && result > 0) {
                                    _addToCart(p, qty: result);
                                  }
                                },
                                getImageUrl: _getImageUrl,
                                showOldPrice: false,
                              ),
                              const SizedBox(height: 24),
                              const _SectionHeader(title: 'Product on Sale'),
                              const SizedBox(height: 12),
                              _ProductHorizontalList(
                                products: sale.isNotEmpty ? sale : popular,
                                onAdd: (p) => _addToCart(p),
                                onTap: (p) async {
                                  final result = await Navigator.push<int>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailPage(product: p),
                                    ),
                                  );
                                  if (result != null && result > 0) {
                                    _addToCart(p, qty: result);
                                  }
                                },
                                getImageUrl: _getImageUrl,
                                showOldPrice: true,
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------- SEARCH BAR ----------------------- */

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search drugs, category...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------------------- PRESCRIPTION BANNER ----------------------- */
class PharmacyBanner extends StatelessWidget {
  final String imagePath;

  const PharmacyBanner({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight / 6,
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F2FF),
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/* ----------------------- SECTION HEADER ----------------------- */

class _SectionHeader extends StatelessWidget {
  final String title;
  final void Function()? onTap;

  const _SectionHeader({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            'See all',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.teal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------------------- PRODUCT LIST ----------------------- */

class _ProductHorizontalList extends StatelessWidget {
  final List<PharmacyProduct> products;
  final bool showOldPrice;
  final void Function(PharmacyProduct) onAdd;
  final void Function(PharmacyProduct) onTap;
  final String Function(PharmacyProduct) getImageUrl;

  const _ProductHorizontalList({
    required this.products,
    required this.showOldPrice,
    required this.onAdd,
    required this.onTap,
    required this.getImageUrl,
  });

  String _price(double price) => '₹${price.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          final imageUrl = getImageUrl(p);
          final effectivePrice = p.effectivePrice;
          final originalPrice = p.mrp ?? p.price;

          return _ProductCard(
            product: p,
            imageUrl: imageUrl,
            effectivePrice: effectivePrice,
            originalPrice: originalPrice,
            showOldPrice: showOldPrice,
            onTap: () => onTap(p),
            onAdd: () => onAdd(p),
          );
        },
      ),
    );
  }
}

/* ----------------------- PRODUCT CARD ----------------------- */

class _ProductCard extends StatelessWidget {
  final PharmacyProduct product;
  final String imageUrl;
  final double effectivePrice;
  final double originalPrice;
  final bool showOldPrice;
  final void Function()? onTap;
  final void Function()? onAdd;

  const _ProductCard({
    required this.product,
    required this.imageUrl,
    required this.effectivePrice,
    required this.originalPrice,
    required this.showOldPrice,
    this.onTap,
    this.onAdd,
  });

  String _price(double price) => '₹${price.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E7F1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 70,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          Images.medicine,
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Image.asset(
                            Images.medicine,
                            height: 70,
                            fit: BoxFit.contain,
                          );
                        },
                      )
                    : Image.asset(
                        Images.medicine,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              product.sku ?? product.category ?? product.strength ?? '',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _price(effectivePrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (showOldPrice && originalPrice > effectivePrice)
                      Text(
                        _price(originalPrice),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    height: 26,
                    width: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B578),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
