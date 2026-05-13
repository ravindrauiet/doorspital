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
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
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
                        child: _LayeredCardImage(
                          imageProvider:
                              isNetworkImage
                                  ? NetworkImage(imageProvider)
                                  : AssetImage(imageProvider) as ImageProvider,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
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
            ),
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

class _LayeredCardImage extends StatelessWidget {
  final ImageProvider imageProvider;

  const _LayeredCardImage({required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              opacity: 0.22,
              onError: (exception, stackTrace) {},
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Image(
            image: imageProvider,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder:
                (context, error, stackTrace) => const _ImageFallback(),
          ),
        ),
      ],
    );
  }
}
