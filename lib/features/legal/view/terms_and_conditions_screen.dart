import 'package:door/features/components/custom_appbar.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Terms & Conditions', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(),
            const SizedBox(height: 24),
            _buildSection(
              'Welcome to Doorspital',
              'By accessing or using the Doorspital mobile application ("App"), you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, please do not use our services.',
            ),
            _buildSection(
              '1. Platform Services Disclaimer',
              '''Doorspital is a technology platform that connects users with healthcare service providers, including doctors, nurses, and other medical professionals.

IMPORTANT: Doorspital acts solely as an intermediary platform. We do not provide medical advice, diagnosis, or treatment. We are not a healthcare provider.

• Doorspital is NOT responsible for any medical advice, diagnosis, treatment, or outcomes provided by healthcare professionals accessed through this platform.

• All medical decisions and treatments are solely between you and the healthcare provider.

• Doorspital does not guarantee the quality, accuracy, or reliability of any medical services obtained through the platform.

• We do not endorse any specific healthcare provider, medication, or treatment plan.''',
            ),
            _buildSection(
              '2. User Responsibilities',
              '''By using Doorspital, you acknowledge and agree that:

• You are responsible for providing accurate and complete health information to healthcare providers.

• You will verify the credentials and qualifications of any healthcare provider before receiving services.

• You understand that online consultations may have limitations and may not be suitable for all medical conditions.

• You will seek immediate emergency care for life-threatening conditions rather than relying on this platform.

• You are responsible for following up on any medical advice received and seeking in-person care when recommended.''',
            ),
            _buildSection(
              '3. Limitation of Liability',
              '''TO THE MAXIMUM EXTENT PERMITTED BY LAW:

• Doorspital, its owners, employees, and affiliates shall NOT be liable for any direct, indirect, incidental, consequential, or punitive damages arising from:
  - Use of the platform or services
  - Medical treatment or advice received through the platform
  - Actions or omissions of healthcare providers
  - Technical failures or service interruptions
  - Unauthorized access to user data

• Our total liability shall not exceed the amount paid by you for services in the past 12 months.

• Doorspital makes no warranties, express or implied, regarding the platform's fitness for any particular purpose.''',
            ),
            _buildSection(
              '4. Healthcare Provider Relationship',
              '''• Healthcare providers accessible through Doorspital are independent contractors and NOT employees of Doorspital.

• Doorspital does not control the medical judgment or professional conduct of any healthcare provider.

• Any disputes regarding medical services should be addressed directly with the healthcare provider.

• Doorspital reserves the right to remove any provider from the platform at its sole discretion.''',
            ),
            _buildSection(
              '5. Payment Terms',
              '''• All payments for services are processed through secure third-party payment gateways.

• Consultation fees are determined by individual healthcare providers and may vary.

• Refund policies are subject to individual provider policies and Doorspital's refund guidelines.

• Doorspital may charge a platform service fee in addition to provider fees.

• Users are responsible for any applicable taxes on services.''',
            ),
            _buildSection(
              '6. User Accounts',
              '''• You must provide accurate and complete information when creating an account.

• You are responsible for maintaining the confidentiality of your account credentials.

• You must notify us immediately of any unauthorized access to your account.

• Doorspital reserves the right to suspend or terminate accounts for violations of these terms.''',
            ),
            _buildSection(
              '7. Intellectual Property',
              '''• All content, trademarks, and intellectual property on the Doorspital platform are owned by or licensed to Doorspital.

• Users may not copy, modify, distribute, or create derivative works without explicit permission.

• User-generated content remains the property of the user but grants Doorspital a license to use it for platform operations.''',
            ),
            _buildSection(
              '8. Governing Law & Disputes',
              '''• These Terms shall be governed by the laws of India.

• Any disputes arising from these Terms or the use of Doorspital services shall be resolved through arbitration in accordance with applicable laws.

• Users waive any right to participate in class action lawsuits against Doorspital.''',
            ),
            _buildSection(
              '9. Modifications',
              '''• Doorspital reserves the right to modify these Terms at any time.

• Continued use of the platform after modifications constitutes acceptance of the updated Terms.

• Users will be notified of significant changes through the App or via email.''',
            ),
            _buildSection(
              '10. Contact Information',
              '''For questions or concerns about these Terms, please contact us at:

Email: support@doorspital.com

By using Doorspital, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.''',
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
