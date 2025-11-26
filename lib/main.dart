import 'package:door/features/auth/provider/check_box_provider.dart';
import 'package:door/features/chat/provider/chat_media_picker_provider.dart';
import 'package:door/features/home/provider/bottom_navbar_provider.dart';
import 'package:door/features/home/provider/video_player_provider.dart';
import 'package:door/features/onboarding/provider/onboarding_provider.dart';
import 'package:door/features/profile/provider/profile_image_provider.dart';
import 'package:door/features/top_doctors/provider/complaint_text_provider.dart';
import 'package:door/features/top_doctors/provider/doctor_availability_provider.dart';
import 'package:door/features/top_doctors/provider/dotor_titming_provider.dart';
import 'package:door/features/top_doctors/provider/image_provider.dart';
import 'package:door/features/top_doctors/provider/select_consultation_provider.dart';
import 'package:door/routes/route_config.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

double screenWidth = 0.0;
double screenHeight = 0.0;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _initializeRouter();
  }

  Future<void> _initializeRouter() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(kOnboardingCompleteKey) ?? false;
    final authService = AuthService();
    final isAuthenticated = await authService.isAuthenticated();

    final initialLocation = isAuthenticated
        ? RouteConstants.bottomNavBarScreen
        : (hasSeenOnboarding
              ? RouteConstants.welcomeScreen
              : RouteConstants.onboardingScreen);

    setState(() {
      _router = createRouter(initialLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_router == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          useMaterial3: false,
          scaffoldBackgroundColor: AppColors.white,
        ),
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        screenHeight = constraints.maxHeight;
        screenWidth = constraints.maxWidth;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CheckBoxProvider()),
            ChangeNotifierProvider(create: (context) => BottomNavbarProvider()),
            ChangeNotifierProvider(create: (context) => VideoPlayerProvider()),
            ChangeNotifierProvider(create: (context) => DotorTitmingProvider()),
            ChangeNotifierProvider(
              create: (context) => DoctorAvailabilityProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => ComplaintTextProvider(),
            ),
            ChangeNotifierProvider(create: (context) => ImagePickProvider()),
            ChangeNotifierProvider(
              create: (context) => SelectConsultationProvider(),
            ),
            ChangeNotifierProvider(create: (context) => ProfileImageProvider()),
            ChangeNotifierProvider(
              create: (context) => ChatMediaPickerProvider(),
            ),
            ChangeNotifierProvider(create: (context) => OnboardingProvider()),
          ],
          child: MaterialApp.router(
            theme: ThemeData(
              fontFamily: GoogleFonts.poppins().fontFamily,
              useMaterial3: false,
              scaffoldBackgroundColor: AppColors.white,
            ),
            routerConfig: _router!,
            title: 'DoctoSpitals',
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
