// onboarding_provider.dart
import 'package:door/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kOnboardingCompleteKey = 'onboarding_completed';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentPage = 0;

  void onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  Future<void> nextPage(BuildContext context) async {
    if (currentPage < 2) {
      await pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      await _markOnboardingComplete();
      if (!context.mounted) return;
      context.pushReplacementNamed(RouteConstants.welcomeScreen);
    }
  }

  Future<void> skip(BuildContext context) async {
    await _markOnboardingComplete();
    if (!context.mounted) return;
    context.pushReplacementNamed(RouteConstants.welcomeScreen);
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, true);
  }
}
