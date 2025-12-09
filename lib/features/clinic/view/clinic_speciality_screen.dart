import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:door/routes/route_constants.dart';

class ClinicSpecialityScreen extends StatefulWidget {
  const ClinicSpecialityScreen({super.key});

  @override
  State<ClinicSpecialityScreen> createState() => _ClinicSpecialityScreenState();
}

class _ClinicSpecialityScreenState extends State<ClinicSpecialityScreen> {
  int? _selectedIndex = 0; // Default selected to first item

  final List<Map<String, dynamic>> _specialities = [
    {
      'name': 'General\nConsultation',
      'icon': Icons.medical_services_outlined,
    },
    {
      'name': 'Dental Care',
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'name': 'Dermatology',
      'icon': Icons.sentiment_satisfied_alt_outlined,
    },
    {
      'name': 'Cardiology',
      'icon': Icons.monitor_heart_outlined,
    },
    {
      'name': 'ENT',
      'icon': Icons.hearing_outlined,
    },
    {
      'name': 'Orthopedic',
      'icon': Icons.back_hand_outlined,
    },
    {
      'name': 'Neurology',
      'icon': Icons.psychology_outlined,
    },
    {
      'name': 'Pediatrics',
      'icon': Icons.child_care_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Back Button
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Select Speciality',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                'Choose the type of care you need',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),
              // Grid of Specialities
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: _specialities.length,
                  itemBuilder: (context, index) {
                    final speciality = _specialities[index];
                    final isSelected = _selectedIndex == index;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        // Navigate to doctors list for this speciality
                        // Clean up the name for API query (remove newlines)
                        final specialityName = (speciality['name'] as String).replaceAll('\n', ' ');
                        context.pushNamed(
                          RouteConstants.clinicDoctorSelectionScreen,
                          extra: specialityName,
                        );
                      },
                      child: _SpecialityCard(
                        name: speciality['name'] as String,
                        icon: speciality['icon'] as IconData,
                        isSelected: isSelected,
                      ),
                    );
                  },
                ),
              ),
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
  final bool isSelected;

  const _SpecialityCard({
    required this.name,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: const Color(0xFF4A90E2), width: 1.5)
            : Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container - rounded square
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 6),
          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
