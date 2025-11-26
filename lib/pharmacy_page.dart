import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:door/services/pharmacy_product_service.dart';
import 'package:door/services/models/pharmacy_models.dart';
import 'package:door/services/api_client.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  static const _kCartKey = 'pharmacy_cart_v1';
  final PharmacyProductService _productService = PharmacyProductService();
  final ApiClient _apiClient = ApiClient();

  late Future<ProductsResponse> _productsFuture;
  final Map<String, int> _cart = {}; // productId -> quantity
  Map<String, PharmacyProduct> _productsById = {};
  final TextEditingController _searchController = TextEditingController();

  int get _cartItemsCount =>
      _cart.values.fold<int>(0, (sum, q) => sum + (q > 0 ? q : 0));

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
    _loadCartFromLocal();
  }

  @override
  void dispose() {
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
    setState(() {
      _productsFuture = _fetchProducts(search: query.isEmpty ? null : query);
    });
  }

  String _getImageUrl(PharmacyProduct product) {
    if (product.imageUrl.isNotEmpty) {
      final imageUrl = product.imageUrl;
      if (imageUrl.startsWith('http')) {
        return imageUrl;
      } else if (imageUrl.startsWith('/')) {
        // Relative path from backend
        return '${_apiClient.baseUrl.replaceAll('/api', '')}$imageUrl';
      }
      return imageUrl;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    const pillBorder = Color(0xFFE6EBF1);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _cartItemsCount == 0
          ? null
          : _CartBar(itemCount: _cartItemsCount, onGoToCart: _openCart),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _productsFuture = _fetchProducts();
            });
            await _productsFuture;
          },
          child: CustomScrollView(
            slivers: [
              // App Bar row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Pharmacy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _openCart,
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined),
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
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
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
                    ],
                  ),
                ),
              ),

              // Search pill
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: pillBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search drugs, category...',
                        hintStyle: TextStyle(color: Color(0xFF9AA4B2)),
                        prefixIcon: Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Upload prescription banner
              const SliverToBoxAdapter(child: PrescriptionBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Products list
              SliverToBoxAdapter(
                child: FutureBuilder<ProductsResponse>(
                  future: _productsFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const _LoadingSkeleton();
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Failed to load products: ${snap.error}',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: Colors.red,
                              ),
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
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No products available.'),
                      );
                    }

                    // Split into popular and on sale
                    final half = (items.length / 2).ceil();
                    final popular = items.take(half).toList();
                    final sale = items.skip(half).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          title: 'Popular Products',
                          onSeeAll: () {
                            // Could navigate to full list
                          },
                        ),
                        const SizedBox(height: 8),
                        _HorizontalProducts(
                          products: popular,
                          green: const Color(0xFF18C2A5),
                          onAdd: (p) => _addToCart(p),
                          onOpen: (p) async {
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
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(
                          title: 'Products on Sale',
                          onSeeAll: () {},
                        ),
                        const SizedBox(height: 8),
                        _HorizontalProducts(
                          products: sale.isNotEmpty ? sale : popular,
                          green: const Color(0xFF18C2A5),
                          showStrikeThroughOld: true,
                          onAdd: (p) => _addToCart(p),
                          onOpen: (p) async {
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
                        ),
                        const SizedBox(height: 16),
                        SizedBox(height: _cartItemsCount > 0 ? 84 : 0),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================ UI PARTS ============================ */

class PrescriptionBanner extends StatelessWidget {
  const PrescriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final maxImgWidth = (MediaQuery.of(context).size.width * 0.35).clamp(
      110.0,
      160.0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Order quickly with\nPrescription',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement prescription upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prescription upload coming soon'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18C2A5),
                    minimumSize: const Size(170, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Upload Prescription',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Image.asset(
            'assets/med.png',
            height: 100,
            width: maxImgWidth,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
        ],
      ),
    );
  }
}

class _HorizontalProducts extends StatelessWidget {
  const _HorizontalProducts({
    required this.products,
    required this.green,
    required this.onAdd,
    required this.onOpen,
    required this.getImageUrl,
    this.showStrikeThroughOld = false,
  });

  final List<PharmacyProduct> products;
  final Color green;
  final bool showStrikeThroughOld;
  final void Function(PharmacyProduct) onAdd;
  final void Function(PharmacyProduct) onOpen;
  final String Function(PharmacyProduct) getImageUrl;

  String _price(double price) => '₹${price.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = products[i];
          final imageUrl = getImageUrl(p);
          final effectivePrice = p.effectivePrice;
          final originalPrice = p.mrp ?? p.price;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onOpen(p),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE6EBF1)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _ProductImage(
                      imageUrl: imageUrl,
                      productName: p.name,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.description?.isNotEmpty == true
                        ? p.description!
                        : p.category ?? p.sku ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 11.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _price(effectivePrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (showStrikeThroughOld && originalPrice > effectivePrice)
                        Text(
                          _price(originalPrice),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF9AA4B2),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const Spacer(),
                      SizedBox(
                        height: 28,
                        width: 28,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFFAF6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => onAdd(p),
                            icon: Icon(Icons.add, color: green, size: 18),
                            tooltip: 'Add to cart',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl, required this.productName});
  final String imageUrl;
  final String productName;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          height: 90,
          width: 120,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _PlaceholderImage(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _PlaceholderImage();
          },
        ),
      );
    }
    return _PlaceholderImage();
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        'assets/images/medicine.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.medication_outlined),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box({double h = 16, double w = double.infinity}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(8),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8F5),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [box(w: 140, h: 18), const Spacer(), box(w: 60, h: 16)],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Container(
                width: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [box(w: 140, h: 18), const Spacer(), box(w: 60, h: 16)],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Container(
                width: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.itemCount, required this.onGoToCart});
  final int itemCount;
  final VoidCallback onGoToCart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6EBF1))),
        ),
        child: Row(
          children: [
            const Text(
              'Added',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$itemCount item${itemCount == 1 ? '' : 's'} in cart',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onGoToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5DFB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Go to cart',
                  style: TextStyle(color: Colors.white, fontSize: 14.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
