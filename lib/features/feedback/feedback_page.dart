import 'package:flutter/material.dart';
import 'package:door/utils/theme/colors.dart';

/// Feedback page where users can select areas that need improvement
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  // Available feedback categories
  final List<FeedbackCategory> _categories = [
    FeedbackCategory(label: 'Performance', color: AppColors.textSecondary),
    FeedbackCategory(label: 'Bug', color: AppColors.textSecondary),
    FeedbackCategory(label: 'UX', color: const Color(0xFF2DD4BF)), // Teal
    FeedbackCategory(label: 'UI', color: AppColors.textSecondary),
    FeedbackCategory(label: 'Crashes', color: AppColors.textSecondary),
    FeedbackCategory(label: 'Loading', color: const Color(0xFFEF4444)), // Red
    FeedbackCategory(label: 'Support', color: AppColors.textSecondary),
    FeedbackCategory(label: 'Security', color: AppColors.textSecondary),
    FeedbackCategory(label: 'Pricing', color: AppColors.textSecondary),
    FeedbackCategory(label: 'Lag', color: const Color(0xFF8B5CF6)), // Purple
    FeedbackCategory(label: 'Animation', color: const Color(0xFF3B82F6)), // Blue
    FeedbackCategory(label: 'Design', color: AppColors.textSecondary),
    FeedbackCategory(label: 'Marketing', color: AppColors.textSecondary),
  ];

  // Selected categories
  final Set<String> _selectedCategories = {};

  bool get _hasSelection => _selectedCategories.isNotEmpty;

  void _toggleCategory(String label) {
    setState(() {
      if (_selectedCategories.contains(label)) {
        _selectedCategories.remove(label);
      } else {
        _selectedCategories.add(label);
      }
    });
  }

  void _submitFeedback() {
    if (!_hasSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback submitted for: ${_selectedCategories.join(", ")}'),
        backgroundColor: AppColors.success,
      ),
    );

    // Navigate back after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

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
          'Feedback',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Which Of The Area Needs\nImprovement?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Category Chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategories.contains(category.label);
                      return _FeedbackChip(
                        label: category.label,
                        accentColor: category.color,
                        isSelected: isSelected,
                        onTap: () => _toggleCategory(category.label),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          // Submit Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F), // Dark navy blue
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackCategory {
  final String label;
  final Color color;

  FeedbackCategory({required this.label, required this.color});
}

class _FeedbackChip extends StatelessWidget {
  final String label;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackChip({
    required this.label,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if this chip should use accent color when selected
    final bool hasAccentColor = accentColor != AppColors.textSecondary;
    
    // Colors based on selection state
    final Color backgroundColor = isSelected 
        ? (hasAccentColor ? accentColor.withOpacity(0.1) : const Color(0xFFF1F5F9))
        : const Color(0xFFF1F5F9);
    
    final Color borderColor = isSelected 
        ? (hasAccentColor ? accentColor : AppColors.primary)
        : Colors.transparent;
    
    final Color textColor = isSelected 
        ? (hasAccentColor ? accentColor : AppColors.primary)
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
