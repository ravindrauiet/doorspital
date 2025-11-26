import 'package:door/features/components/custom_elevated_button.dart';
import 'package:door/features/components/custom_outlined_button.dart';
import 'package:door/main.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              Images.logo, // <-- Make sure you added your logo
              height: 200, // Adjust size as needed
            ),

            // Title
            const Text(
              "Let's get started!",
              style: TextStyle(
                fontSize: 24, // Matches screenshot
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            const Text(
              "We care for you like family.",
              style: TextStyle(
                fontSize: 15, // Matches screenshot
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Login Button
            SizedBox(
              width: screenWidth / 1.5,
              height: 60, // Good button height
              child: CustomElevatedButton(
                borderRadius: 50,
                label: "Login",
                onPressed: () {
                  context.pushNamed(RouteConstants.signInScreen);
                },
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: screenWidth / 1.5,
              height: 60, // Good button height
              child: CustomOutlinedButton(
                borderRadius: 50,
                label: "Sign Up",
                onPressed: () {
                  context.pushNamed(RouteConstants.signUpScreen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
