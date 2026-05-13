import 'package:door/routes/route_constants.dart';
import 'package:door/features/home/provider/bottom_navbar_provider.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ClinicSpecialityScreen extends StatefulWidget {
  const ClinicSpecialityScreen({super.key});

  @override
  State<ClinicSpecialityScreen> createState() => _ClinicSpecialityScreenState();
}

class _ClinicSpecialityScreenState extends State<ClinicSpecialityScreen> {
  int? _selectedIndex = 0;

  final List<Map<String, dynamic>> _specialities = [
    {
      'name': 'General\nConsultation',
      'icon': Icons.medical_services_outlined,
      'color': const Color(0xFF2F6FED),
    },
    {
      'name': 'Dental Care',
      'icon': Icons.health_and_safety_outlined,
      'color': const Color(0xFF1A9C8F),
    },
    {
      'name': 'Dermatology',
      'icon': Icons.sentiment_satisfied_alt_outlined,
      'color': const Color(0xFFF08A5D),
    },
    {
      'name': 'Cardiology',
      'icon': Icons.monitor_heart_outlined,
      'color': const Color(0xFFE25563),
    },
    {
      'name': 'ENT',
      'icon': Icons.hearing_outlined,
      'color': const Color(0xFF7868E6),
    },
    {
      'name': 'Orthopedic',
      'icon': Icons.back_hand_outlined,
      'color': const Color(0xFF0F9D7A),
    },
    {
      'name': 'Neurology',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFF4C7CF0),
    },
    {
      'name': 'Pediatrics',
      'icon': Icons.child_care_outlined,
      'color': const Color(0xFFE78A2F),
    },
    {
      'name': 'Home Doctor',
      'icon': Icons.home_outlined,
      'color': const Color(0xFF2E8BCA),
    },
    {
      'name': 'Physiotherapy',
      'icon': Icons.accessibility_new_outlined,
      'color': const Color(0xFF0D9B7E),
    },
    {
      'name': 'Yoga Trainer',
      'icon': Icons.self_improvement_outlined,
      'color': const Color(0xFF8D5CF6),
    },
    {
      'name': 'Blood Test',
      'icon': Icons.bloodtype_outlined,
      'color': const Color(0xFFD6527A),
    },
  ];

  void _openSpeciality(Map<String, dynamic> speciality, int index) {
    setState(() {
      _selectedIndex = index;
    });

    final name = speciality['name'] as String;
    final specialityName = name.replaceAll('\n', ' ');

    final isDoorstepService = [
      'Home Doctor',
      'Physiotherapy',
      'Yoga Trainer',
      'Blood Test',
    ].contains(name);

    if (isDoorstepService) {
      context.pushNamed(
        RouteConstants.doorstepServiceDetailsScreen,
        extra: name,
      );
    } else {
      context.pushNamed(
        RouteConstants.clinicDoctorSelectionScreen,
        extra: specialityName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkGrey,
        type: BottomNavigationBarType.fixed,
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
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Color(0xFF1F2A44),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEAF2FF), Color(0xFFF7FBFF)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFD9E6FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Clinic Care',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2F6FED),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Select Speciality',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Choose the type of care you need and we will take you to the right doctor or service.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Color(0xFF667085),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.grid_view_rounded,
                            label: '${_specialities.length} specialities',
                          ),
                          const SizedBox(width: 10),
                          const _InfoChip(
                            icon: Icons.local_hospital_outlined,
                            label: 'Clinic + Home care',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.94,
                  ),
                  itemCount: _specialities.length,
                  itemBuilder: (context, index) {
                    final speciality = _specialities[index];
                    return GestureDetector(
                      onTap: () => _openSpeciality(speciality, index),
                      child: _SpecialityCard(
                        name: speciality['name'] as String,
                        icon: speciality['icon'] as IconData,
                        accentColor: speciality['color'] as Color,
                        isSelected: _selectedIndex == index,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialityCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;

  const _SpecialityCard({
    required this.name,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [accentColor.withOpacity(0.16), Colors.white]
              : const [Colors.white, Color(0xFFFBFCFE)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? accentColor.withOpacity(0.8) : const Color(0xFFE6ECF5),
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? accentColor.withOpacity(0.14)
                : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 18 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              size: 26,
              color: accentColor,
            ),
          ),
          const Spacer(),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                isSelected ? 'Open speciality' : 'View doctors',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? accentColor : const Color(0xFF667085),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: isSelected ? accentColor : const Color(0xFF98A2B3),
              ),
            ],
          ),
          if (isSelected) ...[
            const SizedBox(height: 10),
            Container(
              height: 4,
              width: 46,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2F6FED)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF344054),
            ),
          ),
        ],
      ),
    );
  }
}
