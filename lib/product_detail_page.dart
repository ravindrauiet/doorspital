import 'package:flutter/material.dart';
import 'package:door/services/models/pharmacy_models.dart';
import 'package:door/services/api_client.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});
  final PharmacyProduct product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int qty = 1;
  bool fav = false;
  bool expand = false;
  final ApiClient _apiClient = ApiClient();

  String get priceStr => '₹${widget.product.effectivePrice.toStringAsFixed(2)}';
  String get originalPriceStr =>
      widget.product.mrp != null
          ? '₹${widget.product.mrp!.toStringAsFixed(2)}'
          : '';

  String _getImageUrl() {
    if (widget.product.imageUrl.isNotEmpty) {
      final imageUrl = widget.product.imageUrl;
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
    const primary = Color(0xFF2C49C6);
    const green = Color(0xFF18C2A5);
    final imageUrl = _getImageUrl();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pharmacy',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          Container(
            height: 36,
            width: 36,
            margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              Center(
                child: _ProductImage(
                  imageUrl: imageUrl,
                  productName: widget.product.name,
                ),
              ),
              const SizedBox(height: 18),

              // TITLE + HEART
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.sku?.isNotEmpty == true
                              ? widget.product.sku!
                              : widget.product.strength ??
                                  widget.product.category ??
                                  '',
                          style: const TextStyle(color: Color(0xFF7E8A9A)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      fav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.pinkAccent,
                    ),
                    onPressed: () => setState(() => fav = !fav),
                    splashRadius: 22,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // STARS + RATING (static demo)
              Row(
                children: const [
                  Icon(Icons.star, size: 16, color: Color(0xFFFFB703)),
                  Icon(Icons.star, size: 16, color: Color(0xFFFFB703)),
                  Icon(Icons.star, size: 16, color: Color(0xFFFFB703)),
                  Icon(Icons.star, size: 16, color: Color(0xFFFFB703)),
                  Icon(Icons.star_half, size: 16, color: Color(0xFFFFB703)),
                  SizedBox(width: 6),
                  Text('4.0', style: TextStyle(color: Color(0xFF4C5A6B))),
                ],
              ),
              const SizedBox(height: 16),

              // QTY + ADD + PRICE
              Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () => setState(() => qty = qty > 1 ? qty - 1 : 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    color: green,
                    foreground: Colors.white,
                    onTap: () {
                      if (qty < widget.product.stock) {
                        setState(() => qty += 1);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Only ${widget.product.stock} items available'),
                          ),
                        );
                      }
                    },
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceStr,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.product.mrp != null &&
                          widget.product.mrp! > widget.product.effectivePrice)
                        Text(
                          originalPriceStr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9AA4B2),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // DESCRIPTION
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 8),
              _ExpandableText(
                text: widget.product.description?.isNotEmpty == true
                    ? widget.product.description!
                    : 'No description available for this product.',
                expanded: expand,
                onToggle: () => setState(() => expand = !expand),
              ),
              if (widget.product.brand != null) ...[
                const SizedBox(height: 16),
                _InfoRow(label: 'Brand', value: widget.product.brand!),
              ],
              if (widget.product.category != null) ...[
                const SizedBox(height: 8),
                _InfoRow(label: 'Category', value: widget.product.category!),
              ],
              if (widget.product.dosageForm != null) ...[
                const SizedBox(height: 8),
                _InfoRow(
                    label: 'Dosage Form', value: widget.product.dosageForm!),
              ],
              if (widget.product.strength != null) ...[
                const SizedBox(height: 8),
                _InfoRow(label: 'Strength', value: widget.product.strength!),
              ],
              if (widget.product.isPrescriptionRequired) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prescription required for this product',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // BUY BUTTON
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: widget.product.stock > 0
                  ? () => Navigator.pop<int>(context, qty)
                  : null,
              child: Text(
                widget.product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFFEFF2F6),
    this.foreground = Colors.black87,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 32,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Icon(icon, size: 18, color: foreground),
        ),
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
    Widget placeholder = Container(
      height: 160,
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.asset(
        'assets/images/medicine.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.medication_outlined),
      ),
    );

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          height: 160,
          width: 220,
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

class _ExpandableText extends StatelessWidget {
  const _ExpandableText({
    required this.text,
    required this.expanded,
    required this.onToggle,
    this.maxLines = 4,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final body = Text(
      text,
      maxLines: expanded ? null : maxLines,
      overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      style: const TextStyle(color: Color(0xFF5E6B7A), height: 1.4),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        body,
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            expanded ? 'Read less' : 'Read more',
            style: const TextStyle(
              color: Color(0xFF2C49C6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7E8A9A),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2C49C6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
