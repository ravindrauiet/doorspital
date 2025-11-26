// onboarding_provider.dart
import 'package:door/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentPage = 0;

  void onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  void nextPage(BuildContext context) {
    if (currentPage < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.pushReplacementNamed(RouteConstants.welcomeScreen);
    }
  }

  void skip(BuildContext context) {
    context.pushReplacementNamed(RouteConstants.welcomeScreen);
  }
}
