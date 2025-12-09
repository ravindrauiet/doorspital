import 'dart:io';

import 'package:door/features/articles/view/article_detail_screen.dart';
import 'package:door/features/articles/view/articles_list_screen.dart';
import 'package:door/features/cart/view/cart_screen.dart';
import 'package:door/features/chat/view/chat_image_preview_screen.dart';
import 'package:door/features/chat/view/chat_list_screen.dart';
import 'package:door/features/chat/view/chat_screen.dart';
import 'package:door/features/home/view/bottom_nav_bar.dart';
import 'package:door/features/home/view/home_screen.dart';
import 'package:door/features/notificatoins/view/notifications_screen.dart';
import 'package:door/features/onboarding/view/onboarding_screen.dart';
import 'package:door/features/pharmacy/view/pharmacy_home_screen.dart';
import 'package:door/features/pharmacy/view/pharmacy_products_details_screen.dart';
import 'package:door/features/profile/view/edit_profile_screen.dart';
import 'package:door/features/top_doctors/view/doctor_details_screen.dart';
import 'package:door/features/top_doctors/view/patient_details_screen.dart';
import 'package:door/features/top_doctors/view/payment_success_screen.dart';
import 'package:door/features/top_doctors/view/place_appointment_screen.dart';
import 'package:door/features/top_doctors/view/select_package_screen.dart';
import 'package:door/features/top_doctors/view/top_doctors_screen.dart';
import 'package:door/forgot_password_page.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/features/auth/view/sign_in_screen.dart';
import 'package:door/features/auth/view/sign_up_screen.dart';
import 'package:door/features/doorstep_service/view/doorstep_service_details_screen.dart';
import 'package:door/features/doorstep_service/view/doorstep_specialist_details_screen.dart';
import 'package:door/features/legal/view/terms_and_conditions_screen.dart';
import 'package:door/features/legal/view/privacy_policy_screen.dart';
import 'package:door/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

GoRouter createRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    observers: [routeObserver],
    routes: [
      GoRoute(
        path: RouteConstants.homeScreen,
        name: RouteConstants.homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.topDoctorsScreen,
        name: RouteConstants.topDoctorsScreen,
        builder: (context, state) => const TopDoctorsScreen(),
      ),
      GoRoute(
        path: RouteConstants.welcomeScreen,
        name: RouteConstants.welcomeScreen,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboardingScreen,
        name: RouteConstants.onboardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteConstants.signInScreen,
        name: RouteConstants.signInScreen,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RouteConstants.signUpScreen,
        name: RouteConstants.signUpScreen,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteConstants.forgotPasswordScreen,
        name: RouteConstants.forgotPasswordScreen,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteConstants.bottomNavBarScreen,
        name: RouteConstants.bottomNavBarScreen,
        builder: (context, state) => const BottomNavBar(),
      ),
      GoRoute(
        path: RouteConstants.doctorDetailsScreen,
        name: RouteConstants.doctorDetailsScreen,
        builder: (context, state) {
          final doctorId = state.extra as String?;
          return DoctorDetailsScreen(doctorId: doctorId);
        },
      ),
      GoRoute(
        path: RouteConstants.patientDetailsScreen,
        name: RouteConstants.patientDetailsScreen,
        builder: (context, state) => const PatientDetailsScreen(),
      ),
      GoRoute(
        path: RouteConstants.selectPackageScreen,
        name: RouteConstants.selectPackageScreen,
        builder: (context, state) => const SelectPackageScreen(),
      ),
      GoRoute(
        path: RouteConstants.placeAppointmentScreen,
        name: RouteConstants.placeAppointmentScreen,
        builder: (context, state) => const PlaceAppointmentScreen(),
      ),
      GoRoute(
        path: RouteConstants.paymentSuccessScreen,
        name: RouteConstants.paymentSuccessScreen,
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: RouteConstants.notificationsScreen,
        name: RouteConstants.notificationsScreen,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteConstants.editProfileScreen,
        name: RouteConstants.editProfileScreen,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.pharmacyHomeScreen,
        name: RouteConstants.pharmacyHomeScreen,
        builder: (context, state) => const PharmacyHomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.pharmacyProductsDetailsScreen,
        name: RouteConstants.pharmacyProductsDetailsScreen,
        builder: (context, state) => const PharmacyProductsDetailsScreen(),
      ),
      GoRoute(
        path: RouteConstants.cartScreen,
        name: RouteConstants.cartScreen,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: RouteConstants.chatListScreen,
        name: RouteConstants.chatListScreen,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: RouteConstants.chatScreen,
        name: RouteConstants.chatScreen,
        builder: (context, state) {
          final args = state.extra as ChatScreenArgs?;
          return ChatScreen(args: args);
        },
      ),
      GoRoute(
        path: RouteConstants.chatImagePreviewScreen,
        name: RouteConstants.chatImagePreviewScreen,
        builder: (context, state) {
          final file = state.extra as File;
          return ChatImagePreviewScreen(image: file);
        },
      ),
      GoRoute(
        path: RouteConstants.articlesListScreen,
        name: RouteConstants.articlesListScreen,
        builder: (context, state) => const ArticlesListScreen(),
      ),
      GoRoute(
        path: RouteConstants.articleDetailScreen,
        name: RouteConstants.articleDetailScreen,
        builder: (context, state) {
          final article = state.extra as Map<String, String>;
          return ArticleDetailScreen(article: article);
        },
      ),
      GoRoute(
        path: RouteConstants.doorstepServiceDetailsScreen,
        name: RouteConstants.doorstepServiceDetailsScreen,
        builder: (context, state) {
           final serviceId = state.extra as String?;
           return DoorstepServiceDetailsScreen(serviceId: serviceId ?? 'default');
        },
      ),
      GoRoute(
        path: RouteConstants.doorstepSpecialistDetailsScreen,
        name: RouteConstants.doorstepSpecialistDetailsScreen,
        builder: (context, state) {
           final specialistData = state.extra as Map<String, dynamic>;
           return DoorstepSpecialistDetailsScreen(specialistData: specialistData);
        },
      ),
      GoRoute(
        path: RouteConstants.termsAndConditionsScreen,
        name: RouteConstants.termsAndConditionsScreen,
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: RouteConstants.privacyPolicyScreen,
        name: RouteConstants.privacyPolicyScreen,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('404: Page not found (${state.uri.path})')),
    ),
  );
}
