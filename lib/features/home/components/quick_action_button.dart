import 'package:door/main.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String image;
  final void Function()? onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, // Fixed width for better consistency
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2F6), // Light blueish background
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF16A085), // Darker teal for icon bg
                ),
                child: Image.asset(
                  image, 
                  height: 24, 
                  color: Colors.white, // Assuming icons should be white on teal
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500, 
                  fontSize: 13,
                  color: Colors.black87,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
