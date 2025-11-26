import 'package:door/features/components/custom_textfeild.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final VoidCallback onFilterTap;
  const SearchField({super.key, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      radius: 50,
      hint: "Search doctor, drugs, articles…",
      prefixIcon: SizedBox(width: 40, child: Icon(Icons.search, size: 25)),
      suffixIcon: SizedBox(
        width: 40,
        child: Icon(Icons.mic, size: 25, color: AppColors.grey),
      ),
    );
  }
}
