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
      // color: AppColors.black,
      // width: (screenWidth / 3.3fR),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppColors.teal,
              ),
              child: Image.asset(image, height: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
