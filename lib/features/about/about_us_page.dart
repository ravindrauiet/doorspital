import 'package:flutter/material.dart';
import 'package:door/utils/theme/colors.dart';

/// About Us page displaying company information
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.local_hospital,
                size: 50,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 20),
            
            // Company Name
            const Text(
              'Doorspital',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              'Health Assistant Solutions since 2025',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Office Address Card
            _AboutInfoCard(
              icon: Icons.location_on_outlined,
              title: 'Our Office Address',
              details: const [
                'Medicare Tower, A-45,',
                'Green Park Extension,',
                'New Delhi, Delhi - 110016,',
                'India.',
              ],
              onTap: () {
                // Can open maps or show full address
              },
            ),
            
            const SizedBox(height: 16),
            
            // Telephone Card
            _AboutInfoCard(
              icon: Icons.phone_outlined,
              title: 'Our Telephone Number',
              details: const [
                '+91 98123 45678 (Primary)',
                '+91 11456 78910 (Office 1, Delhi)',
                '+91 12048 08765 (Office 2, Noida NCR)',
              ],
              onTap: () {
                // Can initiate a call
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email Card
            _AboutInfoCard(
              icon: Icons.email_outlined,
              title: 'Our Email Address',
              details: const [
                'info@expertmed.in',
                'inquiry@expertmed.in',
                'help@expertmed.in',
              ],
              onTap: () {
                // Can open email client
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _AboutInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> details;
  final VoidCallback? onTap;

  const _AboutInfoCard({
    required this.icon,
    required this.title,
    required this.details,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...details.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      detail,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
