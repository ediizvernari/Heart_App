import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';
import 'package:frontend/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? logo;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color iconColor;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.logo,
    this.onBack,
    this.actions,
    this.iconColor = Colors.white,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context)
            .extension<AppThemeExtension>()
            ?.appBarGradient ??
        AppColors.primaryGradient;

    final canDefaultBack = showBackButton &&
        onBack == null &&
        Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: iconColor),
      automaticallyImplyLeading: canDefaultBack,
      leading: showBackButton && onBack != null
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: onBack,
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logo != null) ...[
            logo!,
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: AppTextStyles.welcomeHeader.copyWith(color: Colors.white),
          ),
        ],
      ),
      centerTitle: true,
      actions: actions,
      flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
    );
  }
}