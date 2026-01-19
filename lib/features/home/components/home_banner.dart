import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:door/features/home/components/home_search_feild.dart';

class HomeBanner extends StatelessWidget {
  final double height;
  final VoidCallback? onBookService;
  final VoidCallback? onSupport;
  final VoidCallback? onPlay;
  final VoidCallback? onSearchTap;

  const HomeBanner({
    super.key,
    this.height = 300,
    this.onBookService,
    this.onSupport,
    this.onPlay,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Elderly Care copy.png'),
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
                Center(
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

                // Bottom Buttons
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 100, // Moved up to make room for SearchBar inside the banner
                  child: Row(
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
                            child: const Center(
                              child: Text(
                                'Book a Service',
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
                      // Support Button
                      Expanded(
                        child: GestureDetector(
                          onTap: onSupport,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Support',
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
            ),
          ),
        ],
      ),
    );
  }
}
