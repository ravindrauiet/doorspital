import 'package:door/features/doorstep_service/models/doorstep_content_model.dart';
import 'package:door/features/doorstep_service/components/service_request_sheet.dart';
import 'package:door/features/doorstep_service/services/doorstep_content_service.dart';
import 'package:door/features/home/provider/bottom_navbar_provider.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/api_client.dart';
import 'package:door/services/doctor_service.dart';
import 'package:door/services/nurse_service.dart';
import 'package:door/services/profile_service.dart';
import 'package:door/services/models/doctor_models.dart';
import 'package:door/services/models/nurse_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DoorstepServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const DoorstepServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<DoorstepServiceDetailsScreen> createState() =>
      _DoorstepServiceDetailsScreenState();
}

class _DoorstepServiceDetailsScreenState
    extends State<DoorstepServiceDetailsScreen> {
  static const String _supportPhoneNumber = '+919837715111';
  static const String _supportWhatsAppNumber = '919837715111';

  final DoorstepContentService _contentService = DoorstepContentService();
  final DoctorService _doctorService = DoctorService();
  final NurseService _nurseService = NurseService();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  bool _isSpecialistsLoading = false;
  DoorstepServiceContent? _serviceDetail;
  List<Doctor> _specialists = [];
  List<PublicNurse> _nurses = [];
  String? _selectedSubCategoryTitle;
  String _leadUserName = '';
  String _leadUserPhone = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _loadLeadContext();
      final detailResponse = await _contentService.getDoorstepServiceDetails(
        widget.serviceId,
      );

      final detail = detailResponse.data;
      if (!detailResponse.success || detail == null) {
        throw Exception(detailResponse.message ?? 'Failed to load service details');
      }

      List<Doctor> doctors = [];
      List<PublicNurse> nurses = [];
      if (_isNurseService(detail)) {
        final nurseResponse = await _nurseService.getPublicNurses(
          service: detail.title,
        );
        nurses = nurseResponse.data ?? [];
      } else {
        final doctorResponse = await _doctorService.getTopDoctors(
          service:
              _isPhysiotherapyService(detail)
                  ? 'Physiotherapy'
                  : (detail.doctorFilterValue.isNotEmpty
                      ? detail.doctorFilterValue
                      : detail.title),
          limit: 20,
        );
        doctors = doctorResponse.data ?? [];
      }

      if (!mounted) return;

      setState(() {
        _serviceDetail = detail;
        _specialists = doctors;
        _nurses = nurses;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLeadContext() async {
    final savedUser = await ApiClient().getUserData();
    _leadUserName =
        savedUser?['userName']?.toString().trim() ??
        savedUser?['name']?.toString().trim() ??
        '';
    _leadUserPhone = savedUser?['phoneNumber']?.toString().trim() ?? '';

    final token = await ApiClient().getToken();
    if (token == null || token.isEmpty) return;

    final profileResponse = await _profileService.getProfile();
    if (!profileResponse.success || profileResponse.data == null) return;

    final profile = profileResponse.data!;
    _leadUserName =
        profile['userName']?.toString().trim() ??
        profile['name']?.toString().trim() ??
        _leadUserName;
    _leadUserPhone =
        profile['phoneNumber']?.toString().trim() ?? _leadUserPhone;
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

  bool _isNurseService(DoorstepServiceContent detail) {
    final key = '${detail.serviceKey} ${detail.title} ${detail.doctorFilterValue}'
        .toLowerCase();
    return key.contains('nurs') || key.contains('caring');
  }

  bool _isPhysiotherapyService(DoorstepServiceContent detail) {
    final key = '${detail.serviceKey} ${detail.title} ${detail.doctorFilterValue}'
        .toLowerCase();
    return key.contains('physio');
  }

  Future<void> _launchCall(String phoneNumber) async {
    final normalized = phoneNumber.trim();
    if (normalized.isEmpty) return;
    final uri = Uri.parse('tel:$normalized');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/$_supportWhatsAppNumber');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchWhatsAppWithMessage(String message) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$_supportWhatsAppNumber?text=$encoded');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _buildWhatsAppLeadMessage({
    required DoorstepServiceContent detail,
    required String providerKind,
    required String providerName,
    String? providerSpecialization,
  }) {
    final selectedService =
        _selectedSubCategoryTitle?.trim().isNotEmpty == true
            ? _selectedSubCategoryTitle!.trim()
            : detail.title.trim();
    final customerName =
        _leadUserName.trim().isNotEmpty ? _leadUserName.trim() : 'Not provided';
    final customerPhone =
        _leadUserPhone.trim().isNotEmpty ? _leadUserPhone.trim() : 'Not provided';
    final selectedProvider =
        providerName.trim().isNotEmpty ? providerName.trim() : 'Not selected';
    final normalizedProviderKind = providerKind.trim().isEmpty
        ? 'provider'
        : '${providerKind.trim()[0].toUpperCase()}${providerKind.trim().substring(1)}';

    return [
      'New doorstep service enquiry',
      'Customer Name: $customerName',
      'Customer Mobile: $customerPhone',
      'Service: ${detail.title.trim()}',
      'Selected Service Option: $selectedService',
      '$normalizedProviderKind: $selectedProvider',
      if (providerSpecialization != null && providerSpecialization.trim().isNotEmpty)
        'Specialization: ${providerSpecialization.trim()}',
    ].join('\n');
  }

  void _openDoctorBooking(String doctorId) {
    if (doctorId.trim().isEmpty) return;
    context.pushNamed(RouteConstants.doctorDetailsScreen, extra: doctorId);
  }

  Future<void> _bookServiceDirectly(DoorstepServiceContent detail) {
    final isNurseService = _isNurseService(detail);
    final isPhysiotherapyService = _isPhysiotherapyService(detail);

    return showServiceRequestSheet(
      context: context,
      serviceType:
          isNurseService
              ? 'nurse'
              : isPhysiotherapyService
              ? 'physiotherapy'
              : 'doctor',
      serviceKey: detail.serviceKey,
      serviceTitle: detail.title,
      providerKind: 'general',
      providerId: '',
      providerName: detail.title,
      providerPhone: _supportPhoneNumber,
      supportPhoneNumber: _supportPhoneNumber,
      supportWhatsAppNumber: _supportWhatsAppNumber,
    );
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
    final isNurseService = _isNurseService(detail);
    final isPhysiotherapyService = _isPhysiotherapyService(detail);
    final isCallBasedService = isNurseService || isPhysiotherapyService;
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
                       fit: BoxFit.contain,
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
                                      isCallBasedService
                                          ? 'Direct contact'
                                          : _selectedSubCategoryTitle == null
                                          ? 'All specialists'
                                          : _selectedSubCategoryTitle!,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => _bookServiceDirectly(detail),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.calendar_month_outlined),
                                label: const Text(
                                  'Book This Service',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (detail.showWhatsIncludedSection) ...[
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
                                    icon: const Icon(
                                      Icons.article_outlined,
                                      size: 16,
                                    ),
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
                      ],
                      if (detail.showSubCategoriesSection &&
                          !isCallBasedService &&
                          activeSubCategories.isNotEmpty) ...[
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
                      if (detail.showAvailableSpecialistsSection) ...[
                        _SectionTitle(
                          title: detail.availableSpecialistsTitle,
                          subtitle:
                              isNurseService
                                  ? 'Active nurses onboarded from admin'
                                  : isPhysiotherapyService
                                      ? 'Call, WhatsApp, or book physiotherapy directly'
                                      : (_selectedSubCategoryTitle == null
                                          ? 'Available experts for this service'
                                          : 'Filtered by $_selectedSubCategoryTitle'),
                        ),
                        const SizedBox(height: 10),
                        if (isNurseService && _nurses.isEmpty)
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
                              const Text(
                                'No nurse records available right now',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () => _launchCall(_supportPhoneNumber),
                                icon: const Icon(Icons.call_outlined),
                                label: const Text('Call Support'),
                              ),
                            ],
                          ),
                        )
                        else if (isNurseService)
                          Column(
                            children: List.generate(_nurses.length, (index) {
                              final nurse = _nurses[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index == _nurses.length - 1 ? 0 : 14,
                                ),
                                child: _EnhancedNurseContactCard(
                                  nurse: nurse,
                                  onCall: () => _launchCall(_supportPhoneNumber),
                                  onWhatsApp: () => _launchWhatsAppWithMessage(
                                    _buildWhatsAppLeadMessage(
                                      detail: detail,
                                      providerKind: 'nurse',
                                      providerName: nurse.fullName,
                                      providerSpecialization:
                                          nurse.specialization,
                                    ),
                                  ),
                                  onBook: () => showServiceRequestSheet(
                                    context: context,
                                    serviceType: 'nurse',
                                    serviceKey: detail.serviceKey,
                                    serviceTitle: detail.title,
                                    providerKind: 'nurse',
                                    providerId: nurse.id,
                                    providerName: nurse.fullName,
                                    providerPhone: _supportPhoneNumber,
                                    supportPhoneNumber: _supportPhoneNumber,
                                    supportWhatsAppNumber: _supportWhatsAppNumber,
                                  ),
                                 ),
                               );
                             }),
                           )
                      else if (_isSpecialistsLoading)
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPhysiotherapyService
                                    ? 'No physiotherapy contacts available right now'
                                    : 'No specialists available right now',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (isPhysiotherapyService) ...[
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () => showServiceRequestSheet(
                                    context: context,
                                    serviceType: 'physiotherapy',
                                    serviceKey: detail.serviceKey,
                                    serviceTitle: detail.title,
                                    providerKind: 'general',
                                    providerId: '',
                                    providerName: 'Support',
                                    providerPhone: _supportPhoneNumber,
                                    supportPhoneNumber: _supportPhoneNumber,
                                    supportWhatsAppNumber: _supportWhatsAppNumber,
                                  ),
                                  icon: const Icon(Icons.key_outlined),
                                  label: const Text('Request Physiotherapy'),
                                ),
                              ],
                            ],
                          ),
                        )
                        else if (isPhysiotherapyService)
                          Column(
                            children: List.generate(_specialists.length, (index) {
                              final specialist = _specialists[index];
                              final phoneNumber =
                                  specialist.phoneNumber?.trim().isNotEmpty ==
                                          true
                                      ? specialist.phoneNumber!.trim()
                                      : _supportPhoneNumber;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      index == _specialists.length - 1 ? 0 : 14,
                                ),
                                child: _EnhancedDoctorContactCard(
                                  doctor: specialist,
                                  onCall: () => _launchCall(phoneNumber),
                                  onWhatsApp: () => _launchWhatsAppWithMessage(
                                    _buildWhatsAppLeadMessage(
                                      detail: detail,
                                      providerKind: 'doctor',
                                      providerName:
                                          specialist.name ??
                                          'Physiotherapy Specialist',
                                      providerSpecialization:
                                          specialist.specialization,
                                    ),
                                  ),
                                  onBook: () => showServiceRequestSheet(
                                    context: context,
                                    serviceType: 'physiotherapy',
                                    serviceKey: detail.serviceKey,
                                    serviceTitle: detail.title,
                                    providerKind: 'doctor',
                                    providerId: specialist.id,
                                    providerName:
                                        specialist.name ??
                                        'Physiotherapy Specialist',
                                    providerPhone: phoneNumber,
                                    supportPhoneNumber: _supportPhoneNumber,
                                    supportWhatsAppNumber: _supportWhatsAppNumber,
                                  ),
                                 ),
                               );
                             }),
                           )
                      else
                        Column(
                          children: List.generate(_specialists.length, (index) {
                            final specialist = _specialists[index];
                            final name = specialist.name ?? 'Doctor';
                            final initial =
                                name.isNotEmpty ? name[0].toUpperCase() : 'D';
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == _specialists.length - 1 ? 0 : 14,
                              ),
                              child: _SpecialistCard(
                                name: name,
                                initial: initial,
                                specialization: specialist.specialization,
                                experienceYears: specialist.experienceYears ?? 0,
                                rating: detail.rating > 0 ? detail.rating : 4.5,
                                width: double.infinity,
                                onBookAppointment: () =>
                                    _openDoctorBooking(specialist.id),
                                onWhatsApp: () => _launchWhatsAppWithMessage(
                                  _buildWhatsAppLeadMessage(
                                    detail: detail,
                                    providerKind: 'doctor',
                                    providerName: name,
                                    providerSpecialization:
                                        specialist.specialization,
                                  ),
                                ),
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
                              ),
                            );
                          }),
                        ),
                      ],
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

class _EnhancedNurseContactCard extends StatelessWidget {
  final PublicNurse nurse;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onBook;

  const _EnhancedNurseContactCard({
    required this.nurse,
    required this.onCall,
    required this.onWhatsApp,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      nurse.qualificationLevel,
      nurse.specialization,
      nurse.city,
    ].where((item) => item.trim().isNotEmpty).toList();
    final primaryTag =
        subtitleParts.isNotEmpty ? subtitleParts.first : 'Nursing support';
    final secondaryTag =
        subtitleParts.length > 1 ? subtitleParts.skip(1).join(' • ') : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EBF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2A44).withOpacity(0.05),
            blurRadius: 14,
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
                radius: 24,
                backgroundColor: const Color(0xFFEFF3FF),
                backgroundImage:
                    nurse.avatarUrl.trim().isNotEmpty ? NetworkImage(nurse.avatarUrl) : null,
                child: nurse.avatarUrl.trim().isEmpty
                    ? Text(
                        nurse.fullName.isNotEmpty
                            ? nurse.fullName[0].toUpperCase()
                            : 'N',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nurse.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FC),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            primaryTag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF8F3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${nurse.experienceYears}+ yrs exp',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18794E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (secondaryTag.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        secondaryTag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E8FB)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All calls are managed by Doorspital support',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: Color(0xFFD6DEFA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.call_outlined, size: 17),
                  label: const Text(
                    'Call',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 46,
                width: 48,
                child: OutlinedButton(
                  onPressed: onWhatsApp,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: Color(0xFFD6DEFA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.chat, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnhancedDoctorContactCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onBook;

  const _EnhancedDoctorContactCard({
    required this.doctor,
    required this.onCall,
    required this.onWhatsApp,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final phoneNumber =
        doctor.phoneNumber?.trim().isNotEmpty == true
            ? doctor.phoneNumber!.trim()
            : _DoorstepServiceDetailsScreenState._supportPhoneNumber;
    final specialistName = doctor.name ?? 'Physiotherapy Specialist';
    final specialization =
        doctor.specialization.isNotEmpty
            ? doctor.specialization
            : 'Physiotherapy';
    final location = doctor.city?.trim().isNotEmpty == true
        ? doctor.city!.trim()
        : 'Location not set';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EBF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2A44).withOpacity(0.05),
            blurRadius: 14,
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
                radius: 24,
                backgroundColor: const Color(0xFFEFF3FF),
                child: Text(
                  specialistName.isNotEmpty
                      ? specialistName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FC),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            specialization,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF8F3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${doctor.experienceYears ?? 0}+ yrs exp',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18794E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E8FB)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_phone_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phoneNumber ==
                            _DoorstepServiceDetailsScreenState._supportPhoneNumber
                        ? 'Call or book to connect with Doorspital support'
                        : 'Call or book to connect with this physiotherapy specialist',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: Color(0xFFD6DEFA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.call_outlined, size: 17),
                  label: const Text(
                    'Call',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 46,
                width: 48,
                child: OutlinedButton(
                  onPressed: onWhatsApp,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: Color(0xFFD6DEFA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.chat, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NurseContactCard extends StatelessWidget {
  final PublicNurse nurse;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onBook;

  const _NurseContactCard({
    required this.nurse,
    required this.onCall,
    required this.onWhatsApp,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      nurse.qualificationLevel,
      nurse.specialization,
      nurse.city,
    ].where((item) => item.trim().isNotEmpty).join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage:
                    nurse.avatarUrl.trim().isNotEmpty ? NetworkImage(nurse.avatarUrl) : null,
                child: nurse.avatarUrl.trim().isEmpty
                    ? Text(
                        nurse.fullName.isNotEmpty ? nurse.fullName[0].toUpperCase() : 'N',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nurse.fullName,
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
                      '${nurse.experienceYears}+ years experience',
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
          const SizedBox(height: 10),
          Text(
            subtitle.isNotEmpty ? subtitle : 'Nursing support',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All calls are managed by Doorspital support',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_outlined, size: 16),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                width: 44,
                child: OutlinedButton(
                  onPressed: onWhatsApp,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.chat, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorContactCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onBook;

  const _DoctorContactCard({
    required this.doctor,
    required this.onCall,
    required this.onWhatsApp,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final phoneNumber =
        doctor.phoneNumber?.trim().isNotEmpty == true
            ? doctor.phoneNumber!.trim()
            : _DoorstepServiceDetailsScreenState._supportPhoneNumber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doctor.name ?? 'Physiotherapy Specialist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            doctor.specialization.isNotEmpty
                ? doctor.specialization
                : 'Physiotherapy',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${doctor.experienceYears ?? 0}+ years • ${doctor.city ?? 'Location not set'}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            phoneNumber,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_outlined, size: 16),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                width: 44,
                child: OutlinedButton(
                  onPressed: onWhatsApp,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.chat, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ],
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
  final VoidCallback onBookAppointment;
  final VoidCallback onWhatsApp;
  final double? width;

  const _SpecialistCard({
    required this.name,
    required this.initial,
    required this.specialization,
    required this.experienceYears,
    required this.rating,
    required this.onChoose,
    required this.onBookAppointment,
    required this.onWhatsApp,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onBookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                width: 44,
                child: OutlinedButton(
                  onPressed: onWhatsApp,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.chat, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: OutlinedButton(
              onPressed: onChoose,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Doctor Profile',
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
        width: double.infinity,
        height: double.infinity,
        child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    }

    final isNetwork = value.startsWith('http://') || value.startsWith('https://');
    final imageProvider =
        isNetwork ? NetworkImage(value) : AssetImage(value) as ImageProvider;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0C8),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                opacity: 0.22,
                onError: (exception, stackTrace) {},
              ),
            ),
          ),
          Container(
            color: const Color(0xFFFFE0C8).withOpacity(0.35),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Image(
              image: imageProvider,
              fit: fit,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFFFE0C8),
                  width: double.infinity,
                  height: double.infinity,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
            ),
          ),
        ],
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
