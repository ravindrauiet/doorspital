import 'package:flutter/material.dart';
import 'package:door/services/models/pharmacy_models.dart';
import 'package:door/services/pharmacy_order_service.dart';
import 'package:door/services/api_client.dart';
import 'package:door/services/models/api_response.dart';
import 'package:door/features/pharmacy/view/address_form_screen.dart';

class CartPage extends StatefulWidget {
  final Map<String, PharmacyProduct> productsById;
  final Map<String, int> quantities;
  final Future<void> Function()? onCheckout;

  const CartPage({
    super.key,
    required this.productsById,
    required this.quantities,
    this.onCheckout,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Map<String, int> _qty;
  final PharmacyOrderService _orderService = PharmacyOrderService();
  final ApiClient _apiClient = ApiClient();
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _qty = Map<String, int>.from(widget.quantities);
    _qty.removeWhere((key, value) => value <= 0);
  }

  String _money(double price) => '₹${price.toStringAsFixed(2)}';

  double _lineTotal(String productId) {
    final p = widget.productsById[productId];
    if (p == null) return 0;
    return p.effectivePrice * (_qty[productId] ?? 0);
  }

  double get _subtotal =>
      _qty.keys.fold(0.0, (sum, id) => sum + _lineTotal(id));

  double get _discount => 0; // Can be calculated from products if needed
  double get _total => _subtotal - _discount;

  void _inc(String id) =>
      setState(() => _qty.update(id, (q) => q + 1, ifAbsent: () => 1));

  void _dec(String id) {
    setState(() {
      final current = _qty[id] ?? 0;
      if (current <= 1) {
        _qty.remove(id);
      } else {
        _qty[id] = current - 1;
      }
    });
  }

  void _remove(String id) => setState(() => _qty.remove(id));

  Future<void> _handleCheckout() async {
    if (_qty.isEmpty) return;

    // Show address form dialog
    final address = await _showAddressDialog();
    if (address == null) return;

    setState(() => _isCheckingOut = true);

    try {
      // Build order items
      final items = _qty.entries
          .map((e) => OrderItemRequest(
                productId: e.key,
                quantity: e.value,
              ))
          .toList();

      final orderRequest = CreateOrderRequest(
        items: items,
        discount: _discount,
        paymentMethod: 'cod',
        shippingAddress: address,
        notes: 'Order from mobile app',
        metadata: {'source': 'mobile-app'},
      );

      final response = await _orderService.createOrder(orderRequest);

      if (response.success) {
        // Clear cart
        await widget.onCheckout?.call();

        // Show success dialog
        if (mounted) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => _PaymentSuccessDialog(
              orderId: response.data?.id,
              onContinue: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop<Map<String, int>>(<String, int>{});
              },
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to place order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  Future<ShippingAddress?> _showAddressDialog() async {
    final result = await Navigator.push<ShippingAddress>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressFormScreen(),
      ),
    );
    return result;
  }

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
    final ids = _qty.keys
        .where((id) => widget.productsById.containsKey(id))
        .toList();

    final appBar = AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black87,
        ),
        onPressed: () => Navigator.pop<Map<String, int>>(context, _qty),
      ),
      title: const Text(
        'My cart',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      ),
      centerTitle: true,
    );

    if (ids.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FB),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.shopping_bag_outlined, size: 56),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add some items from the pharmacy page.',
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop<Map<String, int>>(context, _qty),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5DFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Browse products',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ...ids.map(
            (id) => _CartItemTile(
              product: widget.productsById[id]!,
              qty: _qty[id]!,
              onInc: () => _inc(id),
              onDec: () => _dec(id),
              onRemove: () => _remove(id),
              getImageUrl: _getImageUrl,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Payment Detail',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _row('Subtotal', _money(_subtotal)),
          if (_discount > 0) _row('Discount', _money(_discount)),
          const Divider(height: 16),
          _row('Total', _money(_total), bold: true),
          const SizedBox(height: 18),

          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE6EBF1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('Cash on Delivery (COD)',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                Spacer(),
                Icon(Icons.payment, color: Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _money(_total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isCheckingOut ? null : _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5DFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isCheckingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Checkout',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String left, String right, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(left,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const Spacer(),
            Text(
              right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 15 : 13,
              ),
            ),
          ],
        ),
      );
}

class _CartItemTile extends StatelessWidget {
  final PharmacyProduct product;
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;
  final String Function(PharmacyProduct) getImageUrl;

  const _CartItemTile({
    required this.product,
    required this.qty,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
    required this.getImageUrl,
  });

  String _money(double price) => '₹${price.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final imageUrl = getImageUrl(product);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6EBF1)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CartProductImage(imageUrl: imageUrl, productName: product.name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  product.sku ?? product.category ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: onDec,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$qty',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
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
                          onPressed: onInc,
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                            color: Color(0xFF18C2A5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
              const SizedBox(height: 8),
              Text(
                _money(product.effectivePrice),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartProductImage extends StatelessWidget {
  const _CartProductImage({required this.imageUrl, required this.productName});
  final String imageUrl;
  final String productName;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 48,
      width: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/medicine.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.medication_outlined),
      ),
    );

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          height: 48,
          width: 64,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => placeholder,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder;
          },
        ),
      );
    }
    return placeholder;
  }
}

class _PaymentSuccessDialog extends StatelessWidget {
  final String? orderId;
  final VoidCallback onContinue;

  const _PaymentSuccessDialog({
    required this.onContinue,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(color: const Color(0xFFE6EBF1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: Container(
                  color: const Color(0xFFF4F7FB),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 48,
                      color: Color(0xFF2F5DFB),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2F5DFB), width: 2),
              ),
              child: const Icon(Icons.check, color: Color(0xFF2F5DFB)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thank You',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Order Placed Successfully',
              style: TextStyle(
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            if (orderId != null) ...[
              const SizedBox(height: 6),
              Text(
                'Order ID: ${orderId!.substring(0, 8)}...',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Your order has been placed successfully! You will receive a confirmation soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5DFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
