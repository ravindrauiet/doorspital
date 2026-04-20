import 'package:door/features/home/components/quick_action_button.dart';
import 'package:door/features/home/components/doorstep_service_card.dart'; // Import shared component
import 'package:door/services/article_service.dart';
import 'package:door/services/models/article_model.dart';
import 'package:door/features/home/components/article_card.dart';
import 'package:door/features/home/components/home_banner.dart';
import 'package:door/features/home/models/home_content_model.dart';
import 'package:door/features/home/provider/bottom_navbar_provider.dart';
import 'package:door/features/home/services/home_content_service.dart';
import 'package:door/features/doorstep_service/models/doorstep_content_model.dart';
import 'package:door/features/doorstep_service/services/doorstep_content_service.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:door/services/give_service_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _articleService = ArticleService();
  final _doorstepContentService = DoorstepContentService();
  final _homeContentService = HomeContentService();
  final _giveServiceService = GiveServiceService();
  bool _loading = true;
  List<Article> _articles = [];
  DoorstepPageContent? _doorstepContent;
  HomeContent? _homeContent;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final articleResponse = await _articleService.getArticles();
    final doorstepResponse = await _doorstepContentService.getDoorstepContent();
    final homeResponse = await _homeContentService.getHomeContent();
    
    if (mounted) {
      setState(() {
        if (articleResponse.success && articleResponse.data != null) {
          _articles = articleResponse.data!;
        }
        if (doorstepResponse.success && doorstepResponse.data != null) {
          _doorstepContent = doorstepResponse.data!;
        }
        if (homeResponse.success && homeResponse.data != null) {
          _homeContent = homeResponse.data!;
        }
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomOverlayClearance =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 88;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeBanner(
                backgroundImage:
                    _homeContent?.banner.backgroundImage ??
                    'assets/images/Elderly Care copy.png',
                bookServiceLabel:
                    _homeContent?.banner.bookServiceLabel ?? 'Book a Service',
                giveServiceLabel:
                    _homeContent?.banner.giveServiceLabel ?? 'Give a Service',
                supportLabel: _homeContent?.banner.supportLabel ?? 'Support',
                searchPlaceholder:
                    _homeContent?.banner.searchPlaceholder ??
                    'Search doctor, drugs, articles...',
                onBookService: () {
                  context.read<BottomNavbarProvider>().updateIndex(1);
                },
                onGiveService: _showGiveServiceForm,
                onSupport: () => context.pushNamed(RouteConstants.helpCenterScreen),
                onPlay: _handleBannerVideoTap,
                onSearchTap: () => context.pushNamed(RouteConstants.globalSearchScreen),
              ),
              
              const SizedBox(height: 20),

              // Content sheet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if ((_homeContent?.quickActions.isNotEmpty ?? false)) ...[
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children:
                            _homeContent!.quickActions
                                .where((item) => item.isVisible)
                                .map(
                                  (action) => QuickAction(
                                    icon: Icons.circle,
                                    label: action.label,
                                    image: action.image,
                                    onTap: () => _handleRouteKey(action.routeKey),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 25),
                    ],
                    if ((_doorstepContent?.homeSectionVisible ?? false) &&
                        (_doorstepContent?.homeServices.isNotEmpty ?? false)) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _doorstepContent!.homeSectionTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_doorstepContent!.homeSectionSubtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _doorstepContent!.homeSectionSubtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 140,
                        ),
                        itemCount: _doorstepContent!.homeServices.length,
                        itemBuilder: (context, index) {
                          final service = _doorstepContent!.homeServices[index];
                          return GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                RouteConstants.doorstepServiceDetailsScreen,
                                extra: service.serviceKey,
                              );
                            },
                            child: DoorstepServiceCard(
                              name: service.title,
                              imagePath: service.cardImage,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                    ],
                    if (_homeContent?.departmentsSection.isVisible ?? false) ...[
                      _buildSectionHeader(
                        _homeContent!.departmentsSection.title,
                        _homeContent!.departmentsSection.ctaText,
                        () => _handleRouteKey('top-doctors'),
                      ),
                      if (_homeContent!.departmentsSection.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _homeContent!.departmentsSection.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 140,
                        ),
                        itemCount: _homeContent!.departmentsSection.items.length,
                        itemBuilder: (context, index) {
                          final item = _homeContent!.departmentsSection.items[index];
                          return _HomeGridCard(
                            title: item.title,
                            image: item.image,
                            onTap: () => _handleRouteKey(item.routeKey),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_homeContent?.mostBookedSection.isVisible ?? false) ...[
                      _buildSectionHeader(_homeContent!.mostBookedSection.title),
                      if (_homeContent!.mostBookedSection.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _homeContent!.mostBookedSection.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _homeContent!.mostBookedSection.items.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = _homeContent!.mostBookedSection.items[index];
                            return _MostBookedServiceCard(
                              title: item.title,
                              description: item.description,
                              image: item.image,
                              onTap: () => _handleRouteKey(item.routeKey),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                    if (_homeContent?.promoBanner.isVisible ?? false) ...[
                      _HomePromoBannerCard(
                        eyebrow: _homeContent!.promoBanner.eyebrow,
                        title: _homeContent!.promoBanner.title,
                        description: _homeContent!.promoBanner.description,
                        image: _homeContent!.promoBanner.image,
                        buttonText: _homeContent!.promoBanner.buttonText,
                        startColor: _parseHexColor(_homeContent!.promoBanner.startColor),
                        endColor: _parseHexColor(_homeContent!.promoBanner.endColor),
                        onTap: () => _handleRouteKey(_homeContent!.promoBanner.routeKey),
                      ),
                      const SizedBox(height: 25),
                    ],
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
                            padding: EdgeInsets.fromLTRB(
                              4,
                              10,
                              4,
                              bottomOverlayClearance,
                            ),
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

  Widget _buildSectionHeader(
    String title, [
    String ctaText = '',
    VoidCallback? onTap,
  ]) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        if (ctaText.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            child: Text(
              ctaText,
              style: const TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleBannerVideoTap() async {
    final videoUrl = _homeContent?.banner.videoUrl.trim() ?? '';
    if (videoUrl.isEmpty) return;

    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _handleRouteKey(String routeKey) {
    final value = routeKey.trim();
    if (value.isEmpty) return;

    if (value == 'top-doctors') {
      context.pushNamed(RouteConstants.topDoctorsScreen);
      return;
    }
    if (value == 'pharmacy') {
      context.pushNamed(RouteConstants.pharmacyHomeScreen);
      return;
    }
    if (value == 'clinic') {
      context.pushNamed(RouteConstants.clinicSpecialityScreen);
      return;
    }
    if (value == 'services') {
      context.read<BottomNavbarProvider>().updateIndex(1);
      return;
    }
    if (value.startsWith('department:')) {
      final departmentName = value.substring('department:'.length).trim();
      context.pushNamed(RouteConstants.topDoctorsScreen, extra: departmentName);
      return;
    }
    if (value.startsWith('doorstep:')) {
      final serviceKey = value.substring('doorstep:'.length).trim();
      context.pushNamed(
        RouteConstants.doorstepServiceDetailsScreen,
        extra: serviceKey,
      );
      return;
    }
    if (value.startsWith('service:')) {
      context.read<BottomNavbarProvider>().updateIndex(1);
    }
  }

  Color _parseHexColor(String value) {
    final clean =
        value.replaceAll('#', '').trim().padLeft(6, '0').toUpperCase();
    final normalized = clean.length == 6 ? 'FF$clean' : clean;
    return Color(int.tryParse(normalized, radix: 16) ?? 0xFF2F49D0);
  }

  void _showGiveServiceForm() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _mobileController = TextEditingController();
    String? _selectedProfession;
    bool _isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Give a Service',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedProfession,
                        decoration: InputDecoration(
                          labelText: 'Profession',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.work_outline),
                        ),
                        items: ['Doctor', 'Nurse'].map((String profession) {
                          return DropdownMenuItem<String>(
                            value: profession,
                            child: Text(profession),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setStateModal(() {
                            _selectedProfession = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your profession';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setStateModal(() {
                                      _isSubmitting = true;
                                    });

                                    final success = await _giveServiceService.submitRequest(
                                      _nameController.text.trim(),
                                      _mobileController.text.trim(),
                                      _selectedProfession!,
                                    );

                                    setStateModal(() {
                                      _isSubmitting = false;
                                    });

                                    if (success) {
                                      if (Navigator.canPop(context)) Navigator.pop(context); // Close the modal
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request submitted successfully. We will contact you soon.'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to submit request. Please try again later.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F49D0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


// DoorstepServiceCard moved to components folder

// Most Booked Service Card Widget
class _MostBookedServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final VoidCallback? onTap;

  const _MostBookedServiceCard({
    required this.title,
    required this.description,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: _RemoteOrAssetImage(
                path: image,
                width: 100,
                height: 180,
                fit: BoxFit.cover,
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
      ),
    );
  }
}

class _HomeGridCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback? onTap;

  const _HomeGridCard({
    required this.title,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _RemoteOrAssetImage(path: image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
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
  }
}

class _HomePromoBannerCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final String image;
  final String buttonText;
  final Color startColor;
  final Color endColor;
  final VoidCallback? onTap;

  const _HomePromoBannerCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.image,
    required this.buttonText,
    required this.startColor,
    required this.endColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 4),
                  child: SizedBox(
                    width: 120,
                    height: 130,
                    child: _RemoteOrAssetImage(path: image, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 130,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (eyebrow.isNotEmpty)
                        Text(
                          eyebrow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (eyebrow.isNotEmpty) const SizedBox(height: 6),
                      if (title.isNotEmpty)
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (title.isNotEmpty) const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
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
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Color(0xFF2F49D0),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              buttonText,
                              style: const TextStyle(
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
    );
  }
}

class _RemoteOrAssetImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  const _RemoteOrAssetImage({
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = path.trim();
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder:
            (_, __, ___) => _ImageFallback(width: width, height: height),
      );
    }

    if (imagePath.isEmpty) {
      return _ImageFallback(width: width, height: height);
    }

    return Image.asset(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder:
          (_, __, ___) => _ImageFallback(width: width, height: height),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final double? width;
  final double? height;

  const _ImageFallback({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}


