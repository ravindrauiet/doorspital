import 'package:door/features/components/custom_appbar.dart';
import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int qtyObh = 1;
  int qtyPanadol = 2;

  final double priceObh = 9.99;
  final double pricePanadol = 19.99;

  double get subtotal => qtyObh * priceObh + qtyPanadol * pricePanadol;
  double get taxes => 1.00;
  double get total => subtotal + taxes;
  double get bottomTotal => 28.98; // to match the UI example

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My cart'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart items
                    CartItemCard(
                      title: 'OBH Combi',
                      subtitle: '75ml',
                      imagePath: Images.medicine,
                      price: priceObh,
                      quantity: qtyObh,
                      onQuantityChanged: (val) {
                        setState(() => qtyObh = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    CartItemCard(
                      title: 'Panadol',
                      subtitle: '70ml',
                      imagePath: Images.medicine2,

                      price: pricePanadol,
                      quantity: qtyPanadol,
                      onQuantityChanged: (val) {
                        setState(() => qtyPanadol = val);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Payment detail
                    const Text(
                      'Payment Detail',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SummaryRow(
                      label: 'Subtotal',
                      value: '\$${subtotal.toStringAsFixed(2)}',
                      isTotal: false,
                    ),
                    const SizedBox(height: 6),
                    const SummaryRow(
                      label: 'Taxes',
                      value: '\$1.00',
                      isTotal: false,
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 20),
                    SummaryRow(
                      label: 'Total',
                      value: '\$${total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),

                    // Payment method
                  ],
                ),
              ),
            ),

            // Bottom total + checkout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${bottomTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 150,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        // TODO: navigate to checkout
                      },
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

/* ======================= APP BAR ======================= */

/* ======================= CART ITEM CARD ======================= */
class CartItemCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final double price;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const CartItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.price,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late int qty;

  @override
  void initState() {
    super.initState();
    qty = widget.quantity;
  }

  void updateQty(int val) {
    if (val < 1) return;
    setState(() => qty = val);
    widget.onQuantityChanged(qty);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.imagePath,
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Colors.black54,
                ),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // BOTTOM COUNTER + PRICE (INSIDE BORDER NOW)
          Row(
            children: [
              QuantitySelector(quantity: qty, onChanged: (v) => updateQty(v)),
              const Spacer(),
              Text(
                "\$${widget.price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
/* ======================= QUANTITY SELECTOR ======================= */

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onChanged(quantity - 1),
          child: SizedBox(
            height: 30,
            width: 30,
            child: Center(
              child: Text(
                '−',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onChanged(quantity + 1),
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/* ======================= SUMMARY ROW ======================= */

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.isTotal,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
      color: isTotal ? null : AppColors.greyLight2,
    );

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

/* ======================= PAYMENT METHOD TILE ======================= */

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7F1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1536F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'VISA',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Change',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
