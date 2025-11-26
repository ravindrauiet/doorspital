import 'package:door/utils/images/images.dart';
import 'package:flutter/material.dart';

class FindPharmacyPage extends StatelessWidget {
  const FindPharmacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Images.locationPin),

          const Text(
            'Find pharmacy\nnear you',
            style: TextStyle(
              fontSize: 24,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "It's easy to find pharmacy that is near\nto your location. With just one tap.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
