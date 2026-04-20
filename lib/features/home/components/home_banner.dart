import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:door/features/home/components/home_search_feild.dart';

class HomeBanner extends StatelessWidget {
  final double height;
  final String backgroundImage;
  final String bookServiceLabel;
  final String giveServiceLabel;
  final String supportLabel;
  final String searchPlaceholder;
  final VoidCallback? onBookService;
  final VoidCallback? onGiveService;
  final VoidCallback? onSupport;
  final VoidCallback? onPlay;
  final VoidCallback? onSearchTap;

  const HomeBanner({
    super.key,
    this.height = 360,
    this.backgroundImage = 'assets/images/Elderly Care copy.png',
    this.bookServiceLabel = 'Book a Service',
    this.giveServiceLabel = 'Give a Service',
    this.supportLabel = 'Support',
    this.searchPlaceholder = 'Search doctor, drugs, articles...',
    this.onBookService,
    this.onGiveService,
    this.onSupport,
    this.onPlay,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        backgroundImage.startsWith('http://') ||
        backgroundImage.startsWith('https://');

    // Total height = Image Height (no overlap)
    return SizedBox(
      height: height, 
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Background Image and Content area
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    isNetworkImage
                        ? NetworkImage(backgroundImage)
                        : AssetImage(backgroundImage) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Dark overlay
                Container(
                  color: Colors.black.withOpacity(0.2),
                ),
                
                // Play Button
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: onPlay,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Buttons
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 90, // Added 5px margin to clear search bar completely
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Book a Service Button
                          Expanded(
                            child: GestureDetector(
                              onTap: onBookService,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F49D0),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2F49D0).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    bookServiceLabel,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Give a Service Button
                          Expanded(
                            child: GestureDetector(
                              onTap: onGiveService,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F49D0),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2F49D0).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    giveServiceLabel,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Support Button
                      GestureDetector(
                        onTap: onSupport,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 50,
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  supportLabel,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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

          // Search Bar inside the banner
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SearchField(
              onTap: onSearchTap,
              hint: searchPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}
