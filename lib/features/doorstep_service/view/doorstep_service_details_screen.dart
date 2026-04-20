import 'package:door/features/doorstep_service/models/doorstep_content_model.dart';
import 'package:door/features/doorstep_service/services/doorstep_content_service.dart';
import 'package:door/features/home/provider/bottom_navbar_provider.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/doctor_service.dart';
import 'package:door/services/models/doctor_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DoorstepServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const DoorstepServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<DoorstepServiceDetailsScreen> createState() =>
      _DoorstepServiceDetailsScreenState();
}

class _DoorstepServiceDetailsScreenState
    extends State<DoorstepServiceDetailsScreen> {
  final DoorstepContentService _contentService = DoorstepContentService();
  final DoctorService _doctorService = DoctorService();

  bool _isLoading = true;
  bool _isSpecialistsLoading = false;
  DoorstepServiceContent? _serviceDetail;
  List<Doctor> _specialists = [];
  String? _selectedSubCategoryTitle;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final detailResponse = await _contentService.getDoorstepServiceDetails(
        widget.serviceId,
      );

      final detail = detailResponse.data;
      if (!detailResponse.success || detail == null) {
        throw Exception(detailResponse.message ?? 'Failed to load service details');
      }

      final doctorResponse = await _doctorService.getTopDoctors(
        service:
            detail.doctorFilterValue.isNotEmpty
                ? detail.doctorFilterValue
                : detail.title,
      );

      if (!mounted) return;

      setState(() {
        _serviceDetail = detail;
        _specialists = doctorResponse.data ?? [];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDoctorsForFilter(String filterValue) async {
    if (!mounted) return;
    setState(() {
      _isSpecialistsLoading = true;
    });

    final doctorResponse = await _doctorService.getTopDoctors(service: filterValue);

    if (!mounted) return;
    setState(() {
      _specialists = doctorResponse.data ?? [];
      _isSpecialistsLoading = false;
    });
  }

  Future<void> _handleSubCategoryTap(DoorstepServiceSubCategory item) async {
    final filterValue =
        item.doctorFilterValue.isNotEmpty ? item.doctorFilterValue : item.title;
    if (filterValue.isEmpty) return;

    setState(() {
      _selectedSubCategoryTitle = item.title;
    });
    await _loadDoctorsForFilter(filterValue);
  }

  Future<void> _resetToServiceDoctors(DoorstepServiceContent detail) async {
    setState(() {
      _selectedSubCategoryTitle = null;
    });
    final filterValue =
        detail.doctorFilterValue.isNotEmpty ? detail.doctorFilterValue : detail.title;
    await _loadDoctorsForFilter(filterValue);
  }

  void _showFullDetails() {
    final detail = _serviceDetail;
    if (detail == null || detail.fullDetails.trim().isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  detail.fullDetailsTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  detail.fullDetails,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_serviceDetail == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load service details')),
      );
    }

    final detail = _serviceDetail!;
    final activeSubCategories =
        detail.subCategories.where((item) => item.isActive).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkGrey,
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          context.read<BottomNavbarProvider>().updateIndex(index);
          context.goNamed(RouteConstants.bottomNavBarScreen);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Health Tip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: _ServiceImage(
                      image: detail.bannerImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.12),
                            Colors.black.withOpacity(0.28),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F2A44).withOpacity(0.07),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (detail.shortDescription.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                detail.shortDescription,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.45,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoPill(
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFFFB800),
                                  label:
                                      detail.rating > 0
                                          ? detail.rating.toStringAsFixed(1)
                                          : 'New',
                                ),
                                _InfoPill(
                                  icon: Icons.reviews_outlined,
                                  label: '${detail.reviewsCount}+ reviews',
                                ),
                                _InfoPill(
                                  icon: Icons.groups_rounded,
                                  label:
                                      _selectedSubCategoryTitle == null
                                          ? 'All specialists'
                                          : _selectedSubCategoryTitle!,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8EBF4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.whatsIncludedTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...detail.whatsIncluded.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE9FBF6),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: AppColors.teal,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (detail.fullDetails.trim().isNotEmpty &&
                                detail.detailsCtaText.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _showFullDetails,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: Color(0xFFD9E1FF),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 11,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: const Icon(Icons.article_outlined, size: 16),
                                  label: Text(
                                    detail.detailsCtaText,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (activeSubCategories.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              detail.subCategoriesTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (_selectedSubCategoryTitle != null)
                              TextButton(
                                onPressed: () => _resetToServiceDoctors(detail),
                                child: const Text('Show All'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedSubCategoryTitle == null
                              ? 'Tap a category to filter the doctors below.'
                              : 'Showing doctors for $_selectedSubCategoryTitle',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 126,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: activeSubCategories.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final item = activeSubCategories[index];
                              final isSelected =
                                  _selectedSubCategoryTitle == item.title;
                              return _SubCategoryCard(
                                item: item,
                                isSelected: isSelected,
                                onTap: () => _handleSubCategoryTap(item),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _SectionTitle(
                        title: detail.availableSpecialistsTitle,
                        subtitle:
                            _selectedSubCategoryTitle == null
                                ? 'Available experts for this service'
                                : 'Filtered by $_selectedSubCategoryTitle',
                      ),
                      const SizedBox(height: 10),
                      if (_isSpecialistsLoading)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      else if (_specialists.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE8EBF4)),
                          ),
                          child: const Text(
                            'No specialists available right now',
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      else
                        SizedBox(
                          height: 158,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 6),
                            itemCount: _specialists.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final specialist = _specialists[index];
                              final name = specialist.name ?? 'Doctor';
                              final initial =
                                  name.isNotEmpty ? name[0].toUpperCase() : 'D';
                              return _SpecialistCard(
                                name: name,
                                initial: initial,
                                specialization: specialist.specialization,
                                experienceYears: specialist.experienceYears ?? 0,
                                rating:
                                    detail.rating > 0 ? detail.rating : 4.5,
                                onChoose: () {
                                  context.pushNamed(
                                    RouteConstants
                                        .doorstepSpecialistDetailsScreen,
                                    extra: {
                                      'id': specialist.id,
                                      'name': name,
                                      'specialization':
                                          specialist.specialization,
                                      'experienceYears':
                                          '${specialist.experienceYears ?? 0}',
                                      'rating':
                                          detail.rating > 0
                                              ? detail.rating
                                              : 4.5,
                                      'consultationFee':
                                          specialist.consultationFee,
                                      'about': specialist.about,
                                      'qualification':
                                          specialist.qualification,
                                      'imageUrl': null,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _InfoPill({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor ?? AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubCategoryCard extends StatelessWidget {
  final DoorstepServiceSubCategory item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 156,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2F6FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE6EAF5),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 64,
                width: double.infinity,
                child: _ServiceImage(image: item.image, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSelected ? 'Selected' : 'Tap to view doctors',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                      ),
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

class _SpecialistCard extends StatelessWidget {
  final String name;
  final String initial;
  final String specialization;
  final int experienceYears;
  final double rating;
  final VoidCallback onChoose;

  const _SpecialistCard({
    required this.name,
    required this.initial,
    required this.specialization,
    required this.experienceYears,
    required this.rating,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2A44).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$experienceYears+ years experience',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Tag(text: specialization),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7DD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB800),
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: onChoose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Doctor',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceImage extends StatelessWidget {
  final String image;
  final BoxFit fit;

  const _ServiceImage({required this.image, required this.fit});

  @override
  Widget build(BuildContext context) {
    final value = image.trim();
    if (value.isEmpty) {
      return Container(
        color: const Color(0xFFFFE0C8),
        child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    }

    final isNetwork = value.startsWith('http://') || value.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        value,
        fit: fit,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: const Color(0xFFFFE0C8),
              child: const Center(child: Icon(Icons.broken_image, size: 50)),
            ),
      );
    }

    return Image.asset(
      value,
      fit: fit,
      errorBuilder:
          (context, error, stackTrace) => Container(
            color: const Color(0xFFFFE0C8),
            child: const Center(child: Icon(Icons.broken_image, size: 50)),
          ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
