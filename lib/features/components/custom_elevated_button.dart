import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final TextStyle? textStyle;
  final Widget? icon;

  // NEW
  final bool isLoading;
  final double loaderSize;
  final Color? loaderColor;
  final bool disableWhileLoading;
  final double? width;
  final double? height;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.elevation = 0,
    this.textStyle,
    this.icon,
    this.isLoading = false,
    this.loaderSize = 18,
    this.loaderColor,
    this.disableWhileLoading = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (disableWhileLoading && isLoading)
        ? null
        : onPressed;

    final child = icon == null
        ? Text(
            label,
            style:
                textStyle ??
                TextStyle(
                  color: textColor ?? AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                      color: textColor ?? AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          elevation: elevation,
          backgroundColor: color ?? AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (c, anim) =>
              FadeTransition(opacity: anim, child: c),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loader'),
                  width: loaderSize,
                  height: loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      loaderColor ?? (textColor ?? AppColors.white),
                    ),
                  ),
                )
              : KeyedSubtree(key: const ValueKey('content'), child: child),
        ),
      ),
    );
  }
}
