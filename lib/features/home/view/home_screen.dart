import 'package:door/features/home/components/quick_action_button.dart';
import 'package:door/features/home/components/article_card.dart';
import 'package:door/features/home/components/home_search_feild.dart';
import 'package:door/features/home/components/video_toutorial.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  String _userName = 'User';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _userName = user?.userName ?? 'User';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Blue header
            Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F49D0), Color(0xFF2741BE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Content sheet
            SingleChildScrollView(
              child: Column(
                children: [
                  // const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 40,
                      top: 20,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: .2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              _loading
                                  ? const SizedBox(
                                      height: 28,
                                      width: 100,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              const SizedBox(height: 6),
                              const Text(
                                'How is it going today?',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right-side doctor/person image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image(
                            image: const AssetImage('assets/woman-doctor.png'),
                            width: 120,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // White card sheet
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 14,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchField(onFilterTap: () {}),
                          const SizedBox(height: 16),
                          VideoToutorial(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              QuickAction(
                                icon: Icons.emoji_events_outlined,
                                label: 'Top Doctors',
                                image: "assets/images/sthetiscope.png",
                                onTap: () {
                                  context.pushNamed(
                                    RouteConstants.topDoctorsScreen,
                                  );
                                },
                              ),
                              QuickAction(
                                icon: Icons.local_pharmacy_outlined,
                                label: 'Pharmacy',
                                image: "assets/images/pharmacy.png",
                                onTap: () {
                                  context.pushNamed(
                                    RouteConstants.pharmacyHomeScreen,
                                  );
                                },
                              ),
                              QuickAction(
                                icon: Icons.home_work_outlined,
                                label: 'Clinic',
                                image:
                                    "assets/images/fa-solid_clinic-medical.png",
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: const [
                              Expanded(
                                child: Text(
                                  'Health article',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                'See all',
                                style: TextStyle(
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const ArticleCard(
                            thumbnail: 'assets/delivery.png',
                            title:
                                'The 25 Healthiest Fruits You Can Eat, According to a Nutritionist',
                            date: 'Jun 10, 2023',
                            readTime: '5 min read',
                          ),
                          const SizedBox(height: 12),
                          const ArticleCard(
                            thumbnail: 'assets/delivery.png',
                            title:
                                'The impact of COVID-19 on Healthcare Systems',
                            date: 'Jun 11, 2023',
                            readTime: '3 min read',
                          ),
                        ],
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
