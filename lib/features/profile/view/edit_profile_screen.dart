import 'package:door/features/components/custom_appbar.dart';
import 'package:door/services/profile_service.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileService = ProfileService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  double _weight = 65;
  double _height = 170;
  int _age = 25;
  String _gender = 'prefer_not_to_say';
  DateTime? _dateOfBirth;

  static const List<String> _metroCities = [
    'New Delhi, NCR',
    'Noida',
    'Gurugram',
    'Mumbai',
    'Bengaluru',
    'Hyderabad',
    'Kolkata',
    'Chennai',
    'Pune',
    'Ahmedabad',
  ];

  static const List<String> _languages = [
    'English',
    'Hindi',
    'Bengali',
    'Telugu',
    'Marathi',
    'Tamil',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Punjabi',
  ];

  static const List<String> _allergyOptions = [
    'Peanuts',
    'Dairy',
    'Shellfish',
    'Soy',
    'Gluten',
    'Dust mites',
    'Pollen',
    'Pet dander',
    'Bee stings',
    'Latex',
    'Medication',
    'Chocolate',
  ];

  bool _showAllAllergies = false;
  final Set<String> _selectedAllergies = {};

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await _profileService.getProfile();
    if (!mounted) return;

    if (response.success && response.data != null) {
      _applyProfile(response.data!);
      setState(() => _loading = false);
    } else {
      setState(() {
        _loading = false;
        _error = response.message ?? 'Failed to load profile';
      });
    }
  }

  void _applyProfile(Map<String, dynamic> data) {
    _nameController.text = data['userName'] ?? '';
    _phoneController.text = data['phoneNumber'] ?? '';
    _locationController.text = data['location'] ?? '';
    _languageController.text = data['preferredLanguage'] ?? '';
    _bioController.text = data['bio'] ?? '';
    _gender = (data['gender'] ?? 'prefer_not_to_say').toString();
    _weight = (data['weightKg'] is num)
        ? (data['weightKg'] as num).toDouble()
        : 65;
    _height = (data['heightCm'] is num)
        ? (data['heightCm'] as num).toDouble()
        : 170;

    if (data['dateOfBirth'] != null) {
      try {
        _dateOfBirth = DateTime.parse(data['dateOfBirth']);
        _age = _calculateAge(_dateOfBirth!);
      } catch (_) {
        _dateOfBirth = null;
      }
    }
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    final payload = <String, dynamic>{
      'userName': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'gender': _gender,
      'location': _locationController.text.trim(),
      'preferredLanguage': _languageController.text.trim(),
      'bio': _bioController.text.trim(),
      'weightKg': _weight.round(),
      'heightCm': _height.round(),
    };

    if (_dateOfBirth != null) {
      payload['dateOfBirth'] = _dateOfBirth!.toIso8601String();
    }

    final response = await _profileService.updateProfile(payload);
    if (!mounted) return;

    setState(() => _saving = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Profile updated')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to update profile')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _languageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: CustomAppBar(title: 'Personal Details'),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(.07),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.teal,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text.isEmpty
                                    ? 'Your name'
                                    : _nameController.text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _phoneController.text.isEmpty
                                    ? 'Add phone number'
                                    : _phoneController.text,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildDropdown(
                    label: 'Gender',
                    value: _gender,
                    icon: Icons.wc_outlined,
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                      DropdownMenuItem(
                        value: 'prefer_not_to_say',
                        child: Text('Prefer not to say'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _gender = value);
                      }
                    },
                  ),
                  _buildDropdown(
                    label: 'Location (Metro City)',
                    value: _locationController.text.isNotEmpty
                        ? _locationController.text
                        : _metroCities.first,
                    icon: Icons.location_city_outlined,
                    items: _metroCities
                        .map(
                          (city) => DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _locationController.text = value);
                      }
                    },
                  ),
                  _buildDropdown(
                    label: 'Preferred Language',
                    value: _languageController.text.isNotEmpty
                        ? _languageController.text
                        : _languages.first,
                    icon: Icons.language_outlined,
                    items: _languages
                        .map(
                          (lang) => DropdownMenuItem<String>(
                            value: lang,
                            child: Text(lang),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _languageController.text = value);
                      }
                    },
                  ),
                  _buildAgeSelector(),
                  _buildSlider(
                    label: 'Weight (kg)',
                    value: _weight,
                    min: 40,
                    max: 150,
                    onChanged: (v) => setState(() => _weight = v),
                  ),
                  _buildSlider(
                    label: 'Height (cm)',
                    value: _height,
                    min: 120,
                    max: 220,
                    onChanged: (v) => setState(() => _height = v),
                  ),
                  _buildDriverLicenseSection(context),
                  const SizedBox(height: 18),
                  _buildAllergySection(),
                  const SizedBox(height: 18),
                  _buildMultilineField(
                    label: 'Bio / Notes',
                    controller: _bioController,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon:
                  icon != null ? Icon(icon, color: AppColors.primary) : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon:
                  icon != null ? Icon(icon, color: AppColors.primary) : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: items,
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Age',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, size: 18),
                const SizedBox(width: 12),
                Text(
                  '$_age years',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _roundIconButton(
                  Icons.remove,
                  onTap: () {
                    if (_age > 1) {
                      setState(() {
                        _age--;
                        _dateOfBirth =
                            DateTime(DateTime.now().year - _age, 1, 1);
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                _roundIconButton(
                  Icons.add,
                  onTap: () {
                    setState(() {
                      _age++;
                      _dateOfBirth =
                          DateTime(DateTime.now().year - _age, 1, 1);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ),
          Text(
            value.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverLicenseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driver\'s License / Social Security',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        const Text(
          'Secure verification is on the way. You’ll soon be able to upload your documents safely.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document upload coming soon!')),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7ECF3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.lock_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Tap to upload — Coming soon',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllergySection() {
    final displayAllergies = _showAllAllergies
        ? _allergyOptions
        : _allergyOptions.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Allergies & Reactions',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() => _showAllAllergies = !_showAllAllergies);
              },
              child: Text(_showAllAllergies ? 'Show less' : 'Read more'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayAllergies
              .map((label) => _buildAllergyChip(label))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAllergyChip(String label) {
    final selected = _selectedAllergies.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedAllergies.remove(label);
          } else {
            _selectedAllergies.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal.withOpacity(.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.teal : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: selected ? AppColors.teal : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.teal : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultilineField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
