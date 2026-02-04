import 'package:door/features/home/components/quick_action_button.dart';
import 'package:door/features/home/components/doorstep_service_card.dart'; // Import shared component
import 'package:door/services/article_service.dart';
import 'package:door/services/models/article_model.dart';
import 'package:door/features/home/components/article_card.dart';
import 'package:door/features/home/components/home_search_feild.dart';
import 'package:door/features/home/components/home_banner.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:door/utils/images/images.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _articleService = ArticleService();
  String _userName = 'User';
  bool _loading = true;
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUser();
    final articleResponse = await _articleService.getArticles();
    
    if (mounted) {
      setState(() {
        _userName = user?.userName ?? 'User';
        if (articleResponse.success && articleResponse.data != null) {
          _articles = articleResponse.data!;
        }
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeBanner(
                onBookService: () {
                   context.pushNamed(
                     RouteConstants.doorstepServiceDetailsScreen,
                     extra: 'Elderly Care',
                   );
                },
                onSupport: () => context.pushNamed(RouteConstants.helpCenterScreen),
                onPlay: () {
                  // TODO: Play video
                },
                onSearchTap: () => context.pushNamed(RouteConstants.globalSearchScreen),
              ),
              
              const SizedBox(height: 20),

              // Content sheet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Service Categories (Top Doctors, Pharmacy, Clinic)
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
                                onTap: () {
                                  context.pushNamed(
                                    RouteConstants.clinicSpecialityScreen,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          // Doorstep Service Section
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Doorstep Service',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              final services = [
                                {'name': 'Elderly Care', 'image': 'assets/images/Elderly Care copy.png'},
                                {'name': 'Vet Care', 'image': 'assets/images/Home Doctor copy.png'}, // Placeholder image
                                {'name': 'Nursing & Caring', 'image': 'assets/images/Nursing & Caring copy.png'},
                              ];
                                return GestureDetector(
                                  onTap: () {
                                    context.pushNamed(
                                      RouteConstants.doorstepServiceDetailsScreen,
                                      extra: services[index]['name'] as String,
                                    );
                                  },
                                  child: DoorstepServiceCard(
                                    name: services[index]['name'] as String,
                                    imagePath: services[index]['image'] as String,
                                  ),
                                );
                            },
                          ),
                          const SizedBox(height: 25),
                          // Hospital Departments Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Hospital Departments',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to view all departments/doctors
                                  context.pushNamed(RouteConstants.topDoctorsScreen);
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Departments Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              final departments = [
                                {'name': 'Dental', 'image': 'assets/images/dental_dept.png'}, 
                                {'name': 'OPD', 'image': 'assets/images/opd_dept.png'},
                                {'name': 'Skin', 'image': 'assets/images/skin_dept.png'},
                                {'name': 'ENT', 'image': 'assets/images/ent_dept.png'},
                                {'name': 'Ortho', 'image': 'assets/images/ortho_dept.png'},
                                {'name': 'Cardio', 'image': 'assets/images/cardio_dept.png'},
                                {'name': 'Home Doctor', 'image': 'assets/images/Home Doctor copy.png'},
                                {'name': 'Physiotherapy', 'image': 'assets/images/Physiotherapy copy.png'},
                                {'name': 'Yoga Trainer', 'image': 'assets/images/Yoga Trainer copy.png'},
                                {'name': 'Blood Test', 'image': 'assets/images/Blood Test copy.png'},
                              ];
                              
                              final dept = departments[index];
                              
                              return GestureDetector(
                                onTap: () => context.pushNamed(
                                  RouteConstants.topDoctorsScreen,
                                  extra: dept['name'],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.asset(
                                              dept['image']!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Center(
                                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Flexible(
                                        flex: 1,
                                        child: Text(
                                          dept['name']!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          // Most Booked Services Section
                          const Text(
                            'Most Booked Services',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _MostBookedServiceCard(
                                  title: 'Post-Operative Care',
                                  description: 'Professional care after your surgery for a smooth recovery.',
                                  image: 'assets/images/checkup.png',
                                ),
                                const SizedBox(width: 12),
                                _MostBookedServiceCard(
                                  title: 'Vaccination',
                                  description: 'Get your required vaccinations without leaving home.',
                                  image: 'assets/images/doctor.png',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          // Wellness Banner
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2F49D0), Color(0xFF18C2A5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                children: [
                                  // Right side illustration
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12,
                                        bottom: 4,
                                      ),
                                      child: Image.asset(
                                        Images.medicine,
                                        height: 130,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                    // Left side text
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      right: 140, // Constraint to avoid image overlap
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Stay on top of your health',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              'Book doorstep services, video, medicines.',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                                ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                            const SizedBox(height: 14),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(
                                                    Icons.calendar_today_outlined,
                                                    size: 16,
                                                    color: Color(0xFF2F49D0),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'Book Now',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFF2F49D0),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          // Health Articles Section
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Health article',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                    RouteConstants.articlesListScreen,
                                  );
                                },
                                child: const Text(
                                  'See all',
                                  style: TextStyle(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ..._articles.take(2).map((article) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ArticleCard(
                                  onTap: () {
                                    context.pushNamed(
                                      RouteConstants.articleDetailScreen,
                                      extra: {
                                        'thumbnail': article.image,
                                        'title': article.title,
                                        'date': article.date,
                                        'readTime': article.time,
                                        'content': 'Content fetching not implemented in detail screen yet',
                                      },
                                    );
                                  },
                                  thumbnail: article.image.isNotEmpty ? article.image : 'assets/delivery.png', // Fallback if empty, though unlikely if required
                                  title: article.title,
                                  date: article.date,
                                  readTime: article.time,
                                ),
                              )),
                          if (_articles.isEmpty && !_loading)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No articles found'),
                            ),
                          const SizedBox(height: 20),
                          // Terms & Privacy Footer

                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 10, 4, 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => context.pushNamed(RouteConstants.termsAndConditionsScreen),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF2845A8).withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(color: const Color(0xFFF0F0F0)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE5E8FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.description_outlined,
                                              size: 20,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Terms & Conditions',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => context.pushNamed(RouteConstants.privacyPolicyScreen),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF2845A8).withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(color: const Color(0xFFF0F0F0)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE5E8FF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.shield_outlined,
                                              size: 20,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Privacy Policy',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}


// DoorstepServiceCard moved to components folder

// Most Booked Service Card Widget
class _MostBookedServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const _MostBookedServiceCard({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.asset(
              image,
              width: 100,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 180,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


