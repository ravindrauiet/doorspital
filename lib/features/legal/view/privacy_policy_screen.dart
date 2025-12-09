import 'package:door/features/components/custom_appbar.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Privacy Policy', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'Doorspital ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            _buildSection(
              '1. Information We Collect',
              '''We may collect the following types of information:

Personal Information:
• Name, email address, and phone number
• Date of birth and gender
• Profile photo (optional)
• Address and location data

Health Information:
• Medical history shared with healthcare providers
• Appointment details and consultation records
• Prescriptions and treatment information

Technical Information:
• Device information and identifiers
• IP address and browser type
• App usage data and analytics
• Push notification tokens''',
            ),
            _buildSection(
              '2. How We Use Your Information',
              '''We use your information to:

• Provide and maintain our services
• Connect you with healthcare providers
• Process appointments and payments
• Send notifications about your appointments
• Improve our platform and user experience
• Respond to your inquiries and provide support
• Comply with legal obligations
• Detect and prevent fraud or abuse''',
            ),
            _buildSection(
              '3. Information Sharing',
              '''We may share your information with:

Healthcare Providers:
• To facilitate consultations and medical services
• Only with providers you choose to consult

Service Providers:
• Payment processors for transactions
• Cloud services for data storage
• Analytics providers for app improvement

Legal Requirements:
• When required by law or court order
• To protect our rights and safety
• In response to government requests

We do NOT sell your personal information to third parties.''',
            ),
            _buildSection(
              '4. Data Security',
              '''We implement appropriate security measures including:

• Encryption of data in transit and at rest
• Secure authentication mechanisms
• Regular security assessments
• Access controls and monitoring
• Secure data centers

However, no method of transmission over the internet is 100% secure. We cannot guarantee absolute security of your data.''',
            ),
            _buildSection(
              '5. Your Rights',
              '''You have the right to:

• Access your personal information
• Correct inaccurate data
• Request deletion of your data (subject to legal requirements)
• Opt-out of marketing communications
• Download your data in a portable format
• Withdraw consent for data processing

To exercise these rights, please contact us at support@doorspital.com.''',
            ),
            _buildSection(
              '6. Data Retention',
              '''We retain your information:

• Account data: Until you request deletion
• Medical records: As required by healthcare regulations
• Transaction data: As required for tax and legal purposes
• Analytics data: In anonymized form indefinitely

After account deletion, some data may be retained for legal compliance.''',
            ),
            _buildSection(
              '7. Children\'s Privacy',
              '''Our services are not intended for children under 18 years of age without parental consent. We do not knowingly collect information from children under 18. If you believe we have collected data from a child, please contact us immediately.''',
            ),
            _buildSection(
              '8. Third-Party Links',
              '''Our App may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies before providing any information.''',
            ),
            _buildSection(
              '9. Changes to This Policy',
              '''We may update this Privacy Policy from time to time. We will notify you of any changes by:

• Posting the new policy on this page
• Updating the "Last Updated" date
• Sending you an email notification for significant changes

Your continued use of the App after changes constitutes acceptance of the updated policy.''',
            ),
            _buildSection(
              '10. Contact Us',
              '''If you have questions about this Privacy Policy or our data practices, please contact us:

Email: support@doorspital.com

We will respond to your inquiry within a reasonable timeframe.''',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Last Updated: December 2024',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.teal,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
