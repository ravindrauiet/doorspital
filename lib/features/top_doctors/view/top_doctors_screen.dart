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
    'All',
    'Cardiology',
    'Dermatology',
    'Orthopedics',
    'Neurology',
    'Pediatrics',
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
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
                selectedColor: AppColors.teal,
                backgroundColor: Colors.transparent,
                side: BorderSide(
                  color: i == selectedChip ? AppColors.white : AppColors.grey,
                ),
                labelStyle: TextStyle(
                  color: i == selectedChip
                      ? AppColors.white
                      : const Color(0xFF5B6275),
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
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
  const DoctorCard({
    super.key,
    required this.doctor,
    this.onBookmarkTap,
    this.onTap,
  });

  String get _displayName {
    if (doctor.name != null && doctor.name!.isNotEmpty) {
      return '${doctor.name}';
    }
    // If name is missing, show a placeholder instead of specialization
    return 'Dr. (Name not available)';
  }
  String get _specialty => doctor.specialization;
  String get _imageUrl =>
      'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=800';
  double get _rating => 4.7; // Default rating, can be added to API later

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Row(
                children: [
                  // avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 115,
                      height: 115,
                      child: Image.network(
                        _imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // text area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: screenWidth / 1.2,
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            _displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _specialty,
                          style: const TextStyle(
                            color: Color(0xFF6C7280),
                            fontSize: 12,
                          ),
                        ),
                        if (doctor.city != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            doctor.city!,
                            style: const TextStyle(
                              color: Color(0xFF6C7280),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (doctor.consultationFee != null)
                          Row(
                            children: [
                              const Icon(Icons.currency_rupee, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${doctor.consultationFee!.toStringAsFixed(0)}/consultation',
                                style: const TextStyle(
                                  color: Color(0xFF6C7280),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // bookmark icon
            Positioned(
              right: 10,
              top: 10,
              child: InkWell(
                onTap: onBookmarkTap,
                borderRadius: BorderRadius.circular(10),
                child: Icon(Icons.bookmark_border_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
