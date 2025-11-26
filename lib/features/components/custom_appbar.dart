import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool centerTitle;
  final bool showBackButton;
  final Color backgroundColor;
  final Color titleColor;
  final List<Widget>? actions;
  final double elevation;
  final VoidCallback? onBack;
  final Widget? leading;
  final bool? arrowBack;

  const CustomAppBar({
    super.key,
    this.title,
    this.centerTitle = true,
    this.showBackButton = true,
    this.backgroundColor = AppColors.white,
    this.titleColor = AppColors.black,
    this.actions,
    this.elevation = 0,
    this.onBack,
    this.leading,
    this.arrowBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: arrowBack == true ? _buildLeading(context) : null,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      actions: actions,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (!showBackButton) return null;
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new,
        size: 20,
        color: AppColors.black,
      ),
      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
