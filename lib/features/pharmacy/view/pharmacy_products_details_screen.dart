import 'package:door/features/components/custom_appbar.dart';
import 'package:door/main.dart';
import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class PharmacyProductsDetailsScreen extends StatelessWidget {
  const PharmacyProductsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Pharmacy"),
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
                    // Product image
                    Center(
                      child: Image.asset(
                        Images.medicine3, // your product image
                        height: screenHeight / 4.5,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Title + fav
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OBH Combi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '75ml',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.greyLight2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Row(
                                  children: List.generate(
                                    4,
                                    (_) => const Icon(
                                      Icons.star,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '4.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDF0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            size: 18,
                            color: Color(0xFFE74A6B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Quantity + price row
                    Row(
                      children: const [
                        _QuantitySelector(),
                        Spacer(),
                        _PriceText(),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const ReadMoreText(
                      text:
                          'OBH COMBI is a cough medicine containing Paracetamol, Ephedrine HCl, and Chlorphenamine maleate which is used to relieve coughs accompanied by flu symptoms such as fever, headache, and sneezing.',
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom Buy button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    // TODO: handle Buy
                  },
                  child: const Text(
                    'Buy',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

class ReadMoreText extends StatefulWidget {
  final String text;
  final int trimLength; // how many characters before "Read more"

  const ReadMoreText({super.key, required this.text, this.trimLength = 120});

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String visibleText = isExpanded
        ? widget.text
        : widget.text.substring(0, widget.trimLength);

    return GestureDetector(
      onTap: () {
        setState(() => isExpanded = !isExpanded);
      },
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
          children: [
            TextSpan(text: visibleText),
            if (!isExpanded && widget.text.length > widget.trimLength)
              const TextSpan(
                text: '... ',
                style: TextStyle(color: Colors.grey),
              ),
            TextSpan(
              text: isExpanded ? ' Read less' : ' Read more',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- APP BAR ---------------- */

/* ---------------- QUANTITY SELECTOR ---------------- */

class _QuantitySelector extends StatefulWidget {
  const _QuantitySelector();

  @override
  State<_QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<_QuantitySelector> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (quantity > 1) {
              setState(() => quantity--);
            }
          },
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            child: const Text(
              '−',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() => quantity++);
          },
          child: Container(
            height: 30,
            width: 30,
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

/* ---------------- PRICE TEXT ---------------- */

class _PriceText extends StatelessWidget {
  const _PriceText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '\$9.99',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }
}
