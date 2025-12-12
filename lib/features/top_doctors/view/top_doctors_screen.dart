import 'package:door/features/components/custom_appbar.dart';
import 'package:door/main.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/doctor_service.dart';
import 'package:door/services/models/doctor_models.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopDoctorsScreen extends StatefulWidget {
  const TopDoctorsScreen({super.key});

  @override
  State<TopDoctorsScreen> createState() => _TopDoctorsScreenState();
}

class _TopDoctorsScreenState extends State<TopDoctorsScreen> {
  final List<String> chips = const [
    'Heart',
    'Skin',
    'Hair',
    'Kidney',
    'Eyes',
    'Bone',
    'General',
    'Dental',
  ];
  int selectedChip = 0;
  final _doctorService = DoctorService();
  List<Doctor> _doctors = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _doctorService.getTopDoctors(
        specialization: selectedChip > 0 ? chips[selectedChip] : null,
        page: 1,
        limit: 20,
      );

      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _doctors = response.data!;
            _loading = false;
          });
        } else {
          setState(() {
            _error = response.message ?? 'Failed to load doctors';
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _loading = false;
        });
      }
    }
  }

  void _onChipSelected(int index) {
    setState(() {
      selectedChip = index;
    });
    _loadDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: CustomAppBar(
        title: "Top Doctors",
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.search, size: 25, color: AppColors.black),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => ChoiceChip(
                elevation: 0,
                label: Text(chips[i]),
                selected: i == selectedChip,
                onSelected: (_) => _onChipSelected(i),
                selectedColor: const Color(0xFF4AA366),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: i == selectedChip 
                      ? const Color(0xFF4AA366) 
                      : Colors.grey[300]!,
                ),
                labelStyle: TextStyle(
                  color: i == selectedChip
                      ? Colors.white
                      : const Color(0xFF5B6275),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: chips.length,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDoctors,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _doctors.isEmpty
                        ? const Center(
                            child: Text(
                              'No doctors found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (_, i) => DoctorCard(
                              onTap: () {
                                context.pushNamed(
                                  RouteConstants.doctorDetailsScreen,
                                  extra: _doctors[i].id,
                                );
                              },
                              doctor: _doctors[i],
                              index: i,
                              onBookmarkTap: () {},
                            ),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemCount: _doctors.length,
                          ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final void Function()? onTap;
  final VoidCallback? onBookmarkTap;
  final int index;
  
  // List of available doctor images to rotate through
  static const List<String> _doctorImages = [
    'assets/images/doctor.png',
    'assets/images/homepagedocotr.png',
  ];
  
  const DoctorCard({
    super.key,
    required this.doctor,
    this.onBookmarkTap,
    this.onTap,
    this.index = 0,
  });

  String get _doctorImage => _doctorImages[index % _doctorImages.length];

  String get _displayName {
    if (doctor.name != null && doctor.name!.isNotEmpty) {
      return '${doctor.name}';
    }
    // If name is missing, show a placeholder instead of specialization
    return 'Dr. (Name not available)';
  }
  String get _specialty => doctor.specialization;
  double get _rating => 4.7; // Default rating, can be added to API later

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Doctor Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  _doctorImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    _displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  // Specialty
                  Text(
                    _specialty,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.city ?? '800m away',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // Consultation Fee
                  if (doctor.consultationFee != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${doctor.consultationFee!.toStringAsFixed(0)}/consultation',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Bookmark Icon
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: InkWell(
                onTap: onBookmarkTap,
                borderRadius: BorderRadius.circular(8),
                child: Icon(
                  Icons.bookmark_outline,
                  size: 22,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
