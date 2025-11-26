import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class DeliveryPage extends StatelessWidget {
  const DeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // now works
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              Images.onboardingDelivery,
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Get delivery on\nyour door',
            style: TextStyle(
              fontSize: 24,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "It's easy to find pharmacy that is near\nto your location. With just one tap.",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
