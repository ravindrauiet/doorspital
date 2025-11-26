import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double borderWidth;
  final TextStyle? textStyle;
  final Widget? icon;

  /// New optional parameters
  final double? height;
  final double? width;

  const CustomOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.borderWidth = 1.4,
    this.textStyle,
    this.icon,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding,
          side: BorderSide(
            color: borderColor ?? AppColors.primary,
            width: borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: icon == null
            ? Text(
                label,
                style:
                    textStyle ??
                    TextStyle(
                      color: textColor ?? AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style:
                        textStyle ??
                        TextStyle(
                          color: textColor ?? AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
