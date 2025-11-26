import 'package:door/features/components/custom_appbar.dart';
import 'package:door/features/top_doctors/provider/select_consultation_provider.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SelectPackageScreen extends StatelessWidget {
  const SelectPackageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectConsultationProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Select Package'),
      body: SafeArea(
        child: Column(
          children: [
            // BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ).copyWith(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DROPDOWN
                    DropdownButtonFormField<String>(
                      initialValue: provider.selectedDuration,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Select Duration',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: const [
                        DropdownMenuItem(
                          value: '15',
                          child: Text('15 minutes'),
                        ),
                        DropdownMenuItem(
                          value: '30',
                          child: Text('30 minutes'),
                        ),
                        DropdownMenuItem(
                          value: '60',
                          child: Text('60 minutes'),
                        ),
                      ],
                      onChanged: provider.setDuration,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Consultation Type',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _ConsultationCard(
                      type: ConsultationType.messaging,
                      title: 'Messaging',
                      subtitle: 'Chat me up, share photos.',
                      price: '₹499',
                      icon: Icons.chat_bubble_rounded,
                      iconBg: const Color(0xFFFFE4E8),
                    ),
                    _ConsultationCard(
                      type: ConsultationType.audio,
                      title: 'Audio Call',
                      subtitle: 'call your doctor directly.',
                      price: '₹599',
                      icon: Icons.call_rounded,
                      iconBg: const Color(0xFFE3F2FF),
                    ),
                    _ConsultationCard(
                      type: ConsultationType.video,
                      title: 'Video Call',
                      subtitle: 'call your doctor directly.',
                      price: '₹699',
                      icon: Icons.videocam_rounded,
                      iconBg: const Color(0xFFFFF1DD),
                    ),
                    _ConsultationCard(
                      type: ConsultationType.appointment,
                      title: 'Book Appointment',
                      subtitle: 'schedule your visit easily.',
                      price: '₹799',
                      icon: Icons.home_filled,
                      iconBg: const Color(0xFFE6F8EB),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // BOTTOM BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    context.pushNamed(RouteConstants.placeAppointmentScreen);
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final ConsultationType type;
  final String title;
  final String subtitle;
  final String price;
  final IconData icon;
  final Color iconBg;

  const _ConsultationCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectConsultationProvider>(context);
    final bool isSelected = provider.selectedType == type;

    return GestureDetector(
      onTap: () => provider.setType(type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Radio<ConsultationType>(
                  value: type,
                  groupValue: provider.selectedType,
                  activeColor: AppColors.primary,
                  onChanged: provider.setType,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
