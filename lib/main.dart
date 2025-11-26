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
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

double screenWidth = 0.0;
double screenHeight = 0.0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.sizeOf(context).height;
    screenWidth = MediaQuery.sizeOf(context).width;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CheckBoxProvider()),
        ChangeNotifierProvider(create: (context) => BottomNavbarProvider()),
        ChangeNotifierProvider(create: (context) => VideoPlayerProvider()),
        ChangeNotifierProvider(create: (context) => DotorTitmingProvider()),
        ChangeNotifierProvider(create: (context) => DoctorAvailabilityProvider()),
        ChangeNotifierProvider(create: (context) => ComplaintTextProvider()),
        ChangeNotifierProvider(create: (context) => ImagePickProvider()),
        ChangeNotifierProvider(
          create: (context) => SelectConsultationProvider(),
        ),
        ChangeNotifierProvider(create: (context) => ProfileImageProvider()),
        ChangeNotifierProvider(create: (context) => ChatMediaPickerProvider()),
        ChangeNotifierProvider(create: (context) => OnboardingProvider()),
      ],
      child: MaterialApp.router(
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          useMaterial3: false,
          scaffoldBackgroundColor: AppColors.white,
        ),
        routerConfig: appRouter,
        title: 'DoctoSpitals',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
