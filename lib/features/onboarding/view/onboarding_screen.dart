import 'package:door/features/onboarding/components/delivery.dart';
import 'package:door/features/onboarding/components/doctor_advice.dart';
import 'package:door/features/onboarding/components/find_pharmacy.dart';
import 'package:door/features/onboarding/provider/onboarding_provider.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // top bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () => provider.skip(context),
                    child: Text(
                      'Skip',
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // PAGEVIEW
            Expanded(
              child: PageView.builder(
                controller: provider.pageController,
                itemCount: 3,
                onPageChanged: provider.onPageChanged,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return const DoctorAdvicePage();
                    case 1:
                      return const FindPharmacyPage();
                    case 2:
                    default:
                      return const DeliveryPage();
                  }
                },
              ),
            ),

            // bottom area: indicators + next button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Row(
                children: [
                  _OnboardingIndicators(activeIndex: provider.currentPage),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => provider.nextPage(context),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: Offset(0, 4),
                            color: AppColors.black12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingIndicators extends StatelessWidget {
  final int activeIndex;
  const _OnboardingIndicators({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    // 3 simple "line" indicators styled similar to the design
    return Row(
      children: List.generate(3, (index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          height: 4,
          width: isActive ? 26 : 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive ? AppColors.primary : AppColors.lightGrey,
          ),
        );
      }),
    );
  }
}
