import 'package:door/features/home/components/quick_action_button.dart';
import 'package:door/services/article_service.dart';
import 'package:door/services/models/article_model.dart';
import 'package:door/features/home/components/article_card.dart';
import 'package:door/features/home/components/home_search_feild.dart';
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
        child: Stack(
          children: [
            // Blue header
            Container(
              height: 280,
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
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile picture
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: const AssetImage(Images.ruchita),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'welcome!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  _loading
                                      ? const SizedBox(
                                          height: 24,
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
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'How is it going today?',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Right-side doctor illustration
                            Image.asset(
                              'assets/woman-doctor.png',
                              width: 100,
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Search bar overlapping both sections
                        SearchField(onFilterTap: () {}),
                        const SizedBox(height: 5), // No margin after search bar
                      ],
                    ),
                  ),

                  // White card sheet
                  Transform.translate(
                    offset: const Offset(0, 0),
                    child: Container(
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
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          // Doorstep Service Section
                          const Text(
                            'Doorstep Service',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              final services = [
                                {'name': 'Physiotherapy', 'image': 'assets/images/Physiotherapy.png'},
                                {'name': 'Yoga Trainer', 'image': 'assets/images/Yoga Trainer.png'},
                                {'name': 'Elderly Care', 'image': 'assets/images/Elderly Care.png'},
                                {'name': 'Home Doctor', 'image': 'assets/images/Home Doctor.png'},
                                {'name': 'Blood Test', 'image': 'assets/images/Blood Test.png'},
                                {'name': 'Nursing & Caring', 'image': 'assets/images/Nursing & Caring.png'},
                              ];
                                return GestureDetector(
                                  onTap: () {
                                    context.pushNamed(
                                      RouteConstants.doorstepServiceDetailsScreen,
                                      extra: services[index]['name'] as String,
                                    );
                                  },
                                  child: _DoorstepServiceCard(
                                    name: services[index]['name'] as String,
                                    imagePath: services[index]['image'] as String,
                                  ),
                                );
                            },
                          ),
                          const SizedBox(height: 25),
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
    );
  }
}

// Doorstep Service Card Widget
class _DoorstepServiceCard extends StatelessWidget {
  final String name;
  final String imagePath;

  const _DoorstepServiceCard({
    required this.name,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.teal,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

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
