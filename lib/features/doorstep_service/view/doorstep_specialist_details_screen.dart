import 'package:door/routes/route_constants.dart';
import 'package:door/services/doctor_service.dart';
import 'package:door/services/models/doctor_models.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoorstepSpecialistDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> specialistData;

  const DoorstepSpecialistDetailsScreen({
    super.key,
    required this.specialistData,
  });

  @override
  State<DoorstepSpecialistDetailsScreen> createState() =>
      _DoorstepSpecialistDetailsScreenState();
}

class _DoorstepSpecialistDetailsScreenState
    extends State<DoorstepSpecialistDetailsScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = true;
  Doctor? _doctor;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    final doctorId = widget.specialistData['id']?.toString() ?? '';
    if (doctorId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final response = await _doctorService.getDoctor(doctorId);
    if (!mounted) return;

    setState(() {
      _doctor = response.data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fallbackName = widget.specialistData['name']?.toString() ?? 'Doctor';
    final fallbackSpecialization =
        widget.specialistData['specialization']?.toString() ?? 'Specialist';
    final fallbackQualification =
        widget.specialistData['qualification']?.toString() ?? '';
    final fallbackAbout = widget.specialistData['about']?.toString() ?? '';
    final fallbackExperience =
        int.tryParse(widget.specialistData['experienceYears']?.toString() ?? '') ??
        0;
    final fallbackRating =
        (widget.specialistData['rating'] as num?)?.toDouble() ?? 4.5;
    final fallbackFee =
        (widget.specialistData['consultationFee'] as num?)?.toDouble() ?? 799;

    final doctor = _doctor;
    final name = doctor?.name ?? fallbackName;
    final specialization = doctor?.specialization.isNotEmpty == true
        ? doctor!.specialization
        : fallbackSpecialization;
    final qualification =
        (doctor?.qualification?.trim().isNotEmpty ?? false)
            ? doctor!.qualification!.trim()
            : fallbackQualification;
    final experience = doctor?.experienceYears ?? fallbackExperience;
    final consultationFee = doctor?.consultationFee ?? fallbackFee;
    final about =
        (doctor?.about?.trim().isNotEmpty ?? false)
            ? doctor!.about!.trim()
            : (fallbackAbout.trim().isNotEmpty
                ? fallbackAbout.trim()
                : 'Experienced healthcare professional focused on patient care and recovery.');
    final services = doctor?.services.where((item) => item.trim().isNotEmpty).toList() ??
        const <String>[];
    final rating = fallbackRating;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${consultationFee.toStringAsFixed(0)} / session',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Consultation fee',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushNamed(
                        RouteConstants.doctorDetailsScreen,
                        extra: widget.specialistData['id'],
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFFE8EEFF),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'D',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          qualification.isNotEmpty
                              ? '$qualification • $specialization'
                              : specialization,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatChip(
                              icon: Icons.work_outline,
                              label: '$experience+ years',
                            ),
                            _StatChip(
                              icon: Icons.star_rounded,
                              label: rating.toStringAsFixed(1),
                              iconColor: const Color(0xFFFFB800),
                            ),
                            const _StatusChip(label: 'Available'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoCard(
                    title: 'About Doctor',
                    child: Text(
                      about,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Professional Summary',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniInfoTile(
                          label: 'Specialization',
                          value: specialization,
                        ),
                        _MiniInfoTile(
                          label: 'Experience',
                          value: '$experience+ years',
                        ),
                        _MiniInfoTile(
                          label: 'Consultation',
                          value: '₹${consultationFee.toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                  if (services.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'Services Provided',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            services
                                .map((item) => _ServiceTag(label: item))
                                .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MiniInfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _StatChip({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8EBF4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor ?? AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFCF4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD7F3E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, size: 10, color: Color(0xFF12B76A)),
          SizedBox(width: 6),
          Text(
            'Available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12B76A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  final String label;

  const _ServiceTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
