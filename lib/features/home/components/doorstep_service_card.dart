import 'package:flutter/material.dart';
import 'package:door/utils/theme/colors.dart';

class DoorstepServiceCard extends StatelessWidget {
  final String name;
  final String imagePath;

  const DoorstepServiceCard({
    super.key,
    required this.name,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = imagePath.trim();
    final isNetworkImage =
        imageProvider.startsWith('http://') || imageProvider.startsWith('https://');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                imageProvider.isEmpty
                    ? const _ImageFallback()
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          isNetworkImage
                              ? Image.network(
                                imageProvider,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const _ImageFallback(),
                              )
                              : Image.asset(
                                imageProvider,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const _ImageFallback(),
                              ),
                    ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported,
        color: AppColors.teal,
        size: 28,
      ),
    );
  }
}
