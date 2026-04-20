import 'dart:async';

import 'package:door/features/components/custom_textfeild.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/article_service.dart';
import 'package:door/services/doctor_service.dart';
import 'package:door/services/models/article_model.dart';
import 'package:door/services/models/doctor_models.dart';
import 'package:door/services/models/pharmacy_models.dart';
import 'package:door/services/pharmacy_product_service.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DoctorService _doctorService = DoctorService();
  final PharmacyProductService _pharmacyProductService = PharmacyProductService();
  final ArticleService _articleService = ArticleService();

  final List<String> _recentSearches = const [
    'Cardiologist',
    'Dr. Sharma',
    'Dental Clinic',
    'Full Body Checkup',
  ];

  final List<String> _searchSuggestions = const [
    'Cardiologist',
    'Skin specialist',
    'Paracetamol',
    'Blood test',
    'Physiotherapy',
    'Diabetes care',
  ];

  Timer? _debounce;
  bool _isSearching = false;
  String _activeQuery = '';
  int _requestId = 0;

  List<Doctor> _doctorResults = const [];
  List<PharmacyProduct> _medicineResults = const [];
  List<Article> _articleResults = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController
      ..removeListener(_handleQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _handleQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String rawQuery) async {
    final query = rawQuery.trim();
    final currentRequestId = ++_requestId;

    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _activeQuery = '';
        _isSearching = false;
        _doctorResults = const [];
        _medicineResults = const [];
        _articleResults = const [];
      });
      return;
    }

    setState(() {
      _activeQuery = query;
      _isSearching = true;
    });

    final doctorsFuture = _doctorService.getTopDoctors(limit: 50);
    final medicinesFuture = _pharmacyProductService.getProducts(
      search: query,
      limit: 20,
    );
    final articlesFuture = _articleService.getArticles();

    final doctorResponse = await doctorsFuture;
    final medicineResponse = await medicinesFuture;
    final articleResponse = await articlesFuture;

    if (!mounted || currentRequestId != _requestId) return;

    final doctorResults =
        doctorResponse.success && doctorResponse.data != null
            ? doctorResponse.data!
                .where((doctor) => _matchesDoctor(doctor, query))
                .take(8)
                .toList()
            : <Doctor>[];

    final medicineResults =
        medicineResponse.success && medicineResponse.data != null
            ? medicineResponse.data!.items
                .where((item) => _matchesProduct(item, query))
                .take(8)
                .toList()
            : <PharmacyProduct>[];

    final articleResults =
        articleResponse.success && articleResponse.data != null
            ? articleResponse.data!
                .where((article) => _matchesArticle(article, query))
                .take(8)
                .toList()
            : <Article>[];

    setState(() {
      _isSearching = false;
      _doctorResults = doctorResults;
      _medicineResults = medicineResults;
      _articleResults = articleResults;
    });
  }

  bool _matchesDoctor(Doctor doctor, String query) {
    final haystack = [
      doctor.name ?? '',
      doctor.specialization,
      doctor.city ?? '',
      ...doctor.services,
    ].join(' ').toLowerCase();
    return haystack.contains(query.toLowerCase());
  }

  bool _matchesProduct(PharmacyProduct product, String query) {
    final haystack = [
      product.name,
      product.description ?? '',
      product.category ?? '',
      product.brand ?? '',
      product.dosageForm ?? '',
      product.strength ?? '',
      ...(product.tags ?? const <String>[]),
    ].join(' ').toLowerCase();
    return haystack.contains(query.toLowerCase());
  }

  bool _matchesArticle(Article article, String query) {
    final haystack =
        '${article.title} ${article.description} ${article.date}'.toLowerCase();
    return haystack.contains(query.toLowerCase());
  }

  int get _totalResults =>
      _doctorResults.length + _medicineResults.length + _articleResults.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _searchController,
                      hint: 'Search doctor, medicines, etc...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      radius: 30,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _activeQuery.isEmpty
                      ? _buildDefaultContent()
                      : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Recent Searches',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              _recentSearches
                  .map(
                    (search) => InkWell(
                      onTap: () {
                        _searchController.text = search;
                        _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _searchController.text.length),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 8),
                            Text(
                              search,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 32),
        Text(
          'Try Searching For',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Doctors, specializations, medicines, tests, and health articles.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              _searchSuggestions
                  .map(
                    (term) => _SearchSuggestionChip(
                      label: term,
                      onTap: () {
                        _searchController.text = term;
                        _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _searchController.text.length),
                        );
                      },
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          _totalResults == 0
              ? 'No results for "$_activeQuery"'
              : '$_totalResults results for "$_activeQuery"',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (_doctorResults.isNotEmpty) ...[
          const _ResultSectionTitle(title: 'Doctors'),
          const SizedBox(height: 10),
          ..._doctorResults.map(_buildDoctorTile),
          const SizedBox(height: 18),
        ],
        if (_medicineResults.isNotEmpty) ...[
          const _ResultSectionTitle(title: 'Medicines'),
          const SizedBox(height: 10),
          ..._medicineResults.map(_buildMedicineTile),
          const SizedBox(height: 18),
        ],
        if (_articleResults.isNotEmpty) ...[
          const _ResultSectionTitle(title: 'Articles'),
          const SizedBox(height: 10),
          ..._articleResults.map(_buildArticleTile),
        ],
        if (_totalResults == 0)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Try searching by doctor name, specialization, medicine name, or article title.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDoctorTile(Doctor doctor) {
    final subtitleParts = <String>[
      if (doctor.specialization.trim().isNotEmpty) doctor.specialization.trim(),
      if ((doctor.city ?? '').trim().isNotEmpty) doctor.city!.trim(),
    ];

    return _SearchResultTile(
      icon: Icons.person_outline,
      iconColor: const Color(0xFF2563EB),
      title: doctor.name?.trim().isNotEmpty == true ? doctor.name!.trim() : 'Doctor',
      subtitle: subtitleParts.join(' • '),
      trailing: doctor.experienceYears != null
          ? '${doctor.experienceYears} yrs'
          : 'View',
      onTap: () {
        context.pushNamed(
          RouteConstants.doorstepSpecialistDetailsScreen,
          extra: {
            'id': doctor.id,
            'name': doctor.name,
            'specialization': doctor.specialization,
            'qualification': doctor.qualification,
            'experienceYears': doctor.experienceYears,
            'about': doctor.about,
          },
        );
      },
    );
  }

  Widget _buildMedicineTile(PharmacyProduct product) {
    final subtitleParts = <String>[
      if ((product.category ?? '').trim().isNotEmpty) product.category!.trim(),
      if ((product.brand ?? '').trim().isNotEmpty) product.brand!.trim(),
    ];

    return _SearchResultTile(
      icon: Icons.medication_outlined,
      iconColor: const Color(0xFF16A34A),
      title: product.name,
      subtitle: subtitleParts.join(' • '),
      trailing: 'Rs ${product.effectivePrice.toStringAsFixed(0)}',
      onTap: () => context.pushNamed(RouteConstants.pharmacyHomeScreen),
    );
  }

  Widget _buildArticleTile(Article article) {
    return _SearchResultTile(
      icon: Icons.article_outlined,
      iconColor: const Color(0xFFF59E0B),
      title: article.title,
      subtitle: article.description.trim().isNotEmpty
          ? article.description.trim()
          : article.date,
      trailing: article.time,
      onTap: () {
        context.pushNamed(
          RouteConstants.articleDetailScreen,
          extra: {
            'thumbnail': article.image,
            'title': article.title,
            'date': article.date,
            'readTime': article.time,
            'content': article.description,
          },
        );
      },
    );
  }
}

class _ResultSectionTitle extends StatelessWidget {
  final String title;

  const _ResultSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
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
            const SizedBox(width: 8),
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchSuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
