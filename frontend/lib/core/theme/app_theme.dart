import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_text_styles.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: AppColors.primaryBlue,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryBlue,
      ),
      scaffoldBackgroundColor: Colors.white,

      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppTextStyles.welcomeHeader.copyWith(color: Colors.white),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: base.appBarTheme.systemOverlayStyle,
      ),

      extensions: <ThemeExtension<AppThemeExtension>>[
        const AppThemeExtension(
          appBarGradient: AppColors.primaryGradient,
        ),
      ],

      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),

      cardTheme: base.cardTheme.copyWith(
        color: AppColors.cardBackground,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.buttonText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.whiteOverlay,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
      ),

      iconTheme: const IconThemeData(color: AppColors.iconColor),

      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyles.welcomeHeader,
        headlineLarge: AppTextStyles.header,
        titleLarge: AppTextStyles.subheader,
        bodyLarge: AppTextStyles.dialogContent,
        labelLarge: AppTextStyles.buttonText,
      ),
    );
  }
}

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final LinearGradient appBarGradient;

  const AppThemeExtension({required this.appBarGradient});

  @override
  AppThemeExtension copyWith({LinearGradient? appBarGradient}) {
    return AppThemeExtension(
      appBarGradient: appBarGradient ?? this.appBarGradient,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      appBarGradient: LinearGradient.lerp(appBarGradient, other.appBarGradient, t)!,
    );
  }
}
