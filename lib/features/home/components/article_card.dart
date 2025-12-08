import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final String thumbnail;
  final String title;
  final String date;
  final String readTime;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.date,
    required this.readTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EDF3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Stack(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: thumbnail.startsWith('http') || thumbnail.startsWith('https')
                          ? Image.network(
                              thumbnail,
                              width: 90,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 90,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                              ),
                            )
                          : Image.asset(
                              thumbnail,
                              width: 90,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 90,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, size: 24, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$date  •  $readTime',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // space for the bookmark icon
                ],
              ),

              // Bookmark icon positioned at top-right corner
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.bookmark_border,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
