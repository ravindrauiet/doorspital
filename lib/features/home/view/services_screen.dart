import 'package:door/features/doorstep_service/models/doorstep_content_model.dart';
import 'package:door/features/doorstep_service/services/doorstep_content_service.dart';
import 'package:door/features/home/components/doorstep_service_card.dart';
import 'package:door/features/home/components/home_search_feild.dart';
import 'package:door/features/home/models/home_content_model.dart';
import 'package:door/features/home/services/home_content_service.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:door/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final DoorstepContentService _contentService = DoorstepContentService();
  final HomeContentService _homeContentService = HomeContentService();
  bool _isLoading = true;
  String? _error;
  DoorstepPageContent? _content;
  HomeContent? _homeContent;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final response = await _contentService.getDoorstepContent();
    final homeResponse = await _homeContentService.getHomeContent();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _content = response.data;
      }
      if (homeResponse.success && homeResponse.data != null) {
        _homeContent = homeResponse.data;
      }
      if (_content == null && _homeContent == null) {
        _error = response.message ?? 'Failed to load services';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _homeContent?.departmentsSection.title.isNotEmpty == true
        ? _homeContent!.departmentsSection.title
        : (_content?.servicesPageTitle ?? 'All Services');
    final pageSubtitle =
        _homeContent?.departmentsSection.subtitle.isNotEmpty == true
            ? _homeContent!.departmentsSection.subtitle
            : (_content?.servicesPageSubtitle ??
                'Browse departments and care services');
    final services = _content?.servicesPageItems ?? const <DoorstepServiceContent>[];
    final departments =
        _homeContent?.departmentsSection.items ?? const <HomeSectionItem>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.goNamed(RouteConstants.homeScreen),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pageTitle,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pageSubtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SearchField(
                            onTap: () {
                              context.pushNamed(RouteConstants.globalSearchScreen);
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          departments.isEmpty && services.isEmpty
                              ? const Center(child: Text('No services available'))
                              : ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  if (departments.isNotEmpty) ...[
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        'Hospital Departments',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 14,
                                              mainAxisSpacing: 14,
                                              mainAxisExtent: 162,
                                            ),
                                        itemCount: departments.length,
                                        itemBuilder: (context, index) {
                                          final department = departments[index];
                                          return _DepartmentCard(
                                            title: department.title,
                                            image: department.image,
                                            onTap: () {
                                              final routeKey = department.routeKey.trim();
                                              if (routeKey.startsWith('department:')) {
                                                final departmentName = routeKey
                                                    .substring('department:'.length)
                                                    .trim();
                                                context.pushNamed(
                                                  RouteConstants.topDoctorsScreen,
                                                  extra: departmentName,
                                                );
                                                return;
                                              }
                                              context.pushNamed(
                                                RouteConstants.topDoctorsScreen,
                                                extra: department.title,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  if (services.isNotEmpty) ...[
                                    const SizedBox(height: 22),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        'Doorstep Services',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 14,
                                              mainAxisSpacing: 14,
                                              mainAxisExtent: 112,
                                            ),
                                        itemCount: services.length,
                                        itemBuilder: (context, index) {
                                          final service = services[index];
                                          return GestureDetector(
                                            onTap: () {
                                              context.pushNamed(
                                                RouteConstants
                                                    .doorstepServiceDetailsScreen,
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
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                ],
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _DepartmentCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _DepartmentImage(path: image),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentImage extends StatelessWidget {
  final String path;

  const _DepartmentImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final value = path.trim();
    final isNetwork = value.startsWith('http://') || value.startsWith('https://');

    if (value.isEmpty) {
      return Container(
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    return isNetwork
        ? Image.network(
            value,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF1F5F9),
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          )
        : Image.asset(
            value,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF1F5F9),
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
  }
}
