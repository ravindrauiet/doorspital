import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final Color? fillColor;
  final bool readOnly;
  final bool enabled;
  final EdgeInsetsGeometry contentPadding;
  final TextInputAction? textInputAction;
  final double radius;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.fillColor,
    this.readOnly = false,
    this.enabled = true,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    this.textInputAction,
    this.radius = 12,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.radius),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final Color baseFill =
        widget.fillColor ??
        AppColors.background; // soft background like the mock
    final Color baseBorder = AppColors.greySecondry; // thin grey border

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      cursorColor: AppColors.primary,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        isDense: true, // keeps height compact & clean
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: widget.enabled ? baseFill : AppColors.lightGrey,
        // prefix icon with gentle spacing like the screenshot
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                child: IconTheme(
                  data: const IconThemeData(color: AppColors.grey, size: 22),
                  child: widget.prefixIcon!,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: widget.isPassword
            ? IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : (widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: widget.suffixIcon!,
                    )
                  : null),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: widget.contentPadding,

        // Borders – thin light gray like the mock; blue when focused
        border: _border(baseBorder),
        enabledBorder: _border(baseBorder),
        disabledBorder: _border(baseBorder.withValues(alpha: 0.6)),
        focusedBorder: _border(AppColors.primary, width: 1.6),
        errorBorder: _border(AppColors.error, width: 1.6),
        focusedErrorBorder: _border(AppColors.error, width: 1.6),

        // Subtle error text
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          height: 1.2,
        ),
      ),
    );
  }
}
