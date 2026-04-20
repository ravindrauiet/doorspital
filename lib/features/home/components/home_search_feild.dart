import 'package:door/features/components/custom_textfeild.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final VoidCallback? onTap;
  final String hint;

  const SearchField({
    super.key,
    this.onTap,
    this.hint = "Search doctor, drugs, articles...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // Required to let the tap through if needed, but CustomTextField handles it
        elevation: 0,
        borderRadius: BorderRadius.circular(50),
        child: CustomTextField(
          radius: 50,
          hint: hint,
          fillColor: Colors.white,
          readOnly: true, // Make it act like a button
          onTap: onTap, // Handled by CustomTextField -> TextFormField
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 22,
          ),
          prefixIcon: SizedBox(
            width: 50,
            child: Icon(Icons.search, size: 28, color: Colors.grey.shade900),
          ),
          suffixIcon: SizedBox(
            width: 50,
            child: Icon(Icons.mic, size: 28, color: Colors.grey.shade900),
          ),
        ),
      ),
    );
  }
}
