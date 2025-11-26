import 'package:door/features/components/custom_appbar.dart';
import 'package:door/features/components/custom_textfeild.dart';
import 'package:door/features/top_doctors/provider/complaint_text_provider.dart';
import 'package:door/features/top_doctors/provider/image_provider.dart';
import 'package:door/main.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final TextEditingController _name = TextEditingController(text: 'Rifa Noor');
  final TextEditingController _email = TextEditingController(
    text: 'rifanoor221b@gmail.com',
  );
  final TextEditingController _phone = TextEditingController();
  // final TextEditingController complaintCtrl = TextEditingController(
  //   text: 'My ear is in pain last 2 days.',
  // );

  String gender = 'female';
  double height = 179; // 120–180
  double weight = 70; // 60–80

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    // complaintCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintCtrl = context.read<ComplaintTextProvider>().controller;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Patient Details'),
      // Fixed bottom "Continue" button (rounded and elevated like mock)
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              context.pushNamed(RouteConstants.selectPackageScreen);
            },
            style: ElevatedButton.styleFrom(
              elevation: 12,
              shadowColor: AppColors.primary.withValues(alpha: .35),
              backgroundColor: AppColors.primary,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 120,
        ), // keep content clear of bottom pill
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _doctorHeader(),
            _divider(),
            _sectionTitle('Personal Bio'),
            SizedBox(height: 10),
            _labeledField('Your Name', _name, icon: Icons.person_outline),

            _labeledField('Email', _email, icon: Icons.alternate_email),
            _labeledField(
              'Phone Number',
              _phone,
              icon: Icons.call_outlined,
              trailing: _idBadge(),
            ),
            _divider(),
            _sectionTitle('Physical Information'),
            _genderSegmented(),
            const SizedBox(height: 18),
            _rangeHeader('Height', 'centimeter'),

            // In the mock, the tick marks are ABOVE the slider for height
            _thinSlider(
              value: height,
              min: 120,
              max: 180,
              onChanged: (v) => setState(() => height = v.roundToDouble()),
            ),
            _scaleMarks(const [120, 150, 180]),
            const SizedBox(height: 14),
            _rangeHeader('Weight', 'kilograms'),
            // In the mock, the tick marks are BELOW the slider for weight
            _thinSlider(
              value: weight,
              min: 60,
              max: 80,
              onChanged: (v) => setState(() => weight = v.roundToDouble()),
            ),
            _scaleMarks(const [60, 70, 80]),
            _divider(),
            _sectionTitle('Additional Comments'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Main Complaint',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      TextField(
                        controller: complaintCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Write your main complaint',
                          filled: true,
                          fillColor: AppColors.greySecondry,
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.white,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 8,
                        child: Selector<ComplaintTextProvider, int>(
                          selector: (_, m) => m.length,
                          builder: (_, length, __) => Text(
                            '$length/500',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Complaint Photo (Optional)',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Please take a picture of your conditions so the doctor can analyze it beforehand',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer<ImagePickProvider>(
                        builder: (context, value, child) {
                          return GestureDetector(
                            onTap: () {
                              value.pickFromCamera();
                            },
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F1F5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFFE0E2E7)),
                              ),
                              child: const Icon(
                                Icons.photo_camera_outlined,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Consumer<ImagePickProvider>(
                        builder: (context, value, child) {
                          return _outlinedSmall(
                            'Take Photo',
                            onPressed: () {
                              value.pickFromCamera();
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Consumer<ImagePickProvider>(
                        builder: (context, value, child) {
                          return _outlinedSmall(
                            'Upload',
                            onPressed: () {
                              value.pickFromGallery();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Consumer<ImagePickProvider>(
                    builder: (context, value, child) {
                      if (value.imageFiles.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(value.imageFiles.length, (
                          index,
                        ) {
                          final file = value.imageFiles[index];

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: screenHeight / 8,
                                width: screenWidth / 3.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(file, fit: BoxFit.cover),
                                ),
                              ),

                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap: () => value.removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black54,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widgets
  Widget _divider() => const Padding(
    padding: EdgeInsets.only(top: 6, bottom: 6),
    child: Divider(height: 24),
  );

  Widget _doctorHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1607746882042-944635dfe10e?q=80&w=256&auto=format&fit=crop',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Dr. Rishi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF2ECC71),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFFFDFB3)),
                      ),
                      child: const Text(
                        'Psychiatrist',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8A5A00),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '• 501m',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                    Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                    Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                    Icon(Icons.star_border, size: 14, color: Color(0xFFFFC107)),
                    Icon(Icons.star_border, size: 14, color: Color(0xFFFFC107)),
                    SizedBox(width: 4),
                    Text('3.1', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _idBadge() {
    return Container(
      height: 36,
      width: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6EB)),
      ),
      child: const Text(
        'ID',
        style: TextStyle(fontSize: 11, color: Colors.black54),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
    child: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
    ),
  );

  Widget _labeledField(
    String label,
    TextEditingController c, {
    IconData? icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 5),
          CustomTextField(hint: 'Your Name', controller: _name, radius: 5),
        ],
      ),
    );
  }

  // Segmented control matches second screenshot: two options within one capsule, active pill light indigo with light border
  Widget _genderSegmented() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E2E7)),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                _segmentedItem('Male', 'male', left: true),
                _segmentedItem('Female', 'female', right: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentedItem(
    String label,
    String value, {
    bool left = false,
    bool right = false,
  }) {
    final bool active = gender == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => gender = value),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(left ? 28 : 0),
          right: Radius.circular(right ? 28 : 0),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE8EAF6) : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(left ? 28 : 0),
              right: Radius.circular(right ? 28 : 0),
            ),
            border: active
                ? Border.all(color: AppColors.primary)
                : const Border.fromBorderSide(
                    BorderSide(color: Colors.transparent),
                  ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: active ? const Color(0xFF3949AB) : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rangeHeader(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Text(
            right,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _scaleMarks(List<int> marks) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: marks
          .map(
            (m) => Text(
              '$m',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          )
          .toList(),
    ),
  );

  Widget _thinSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          activeTrackColor: AppColors.teal,
          inactiveTrackColor: AppColors.teal.withValues(alpha: 0.35),
          thumbColor: AppColors.teal,
          overlayColor: AppColors.teal,
        ),
        child: Slider(value: value, min: min, max: max, onChanged: onChanged),
      ),
    );
  }

  Widget _outlinedSmall(String label, {void Function()? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Color(0xFFE0E2E7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
