import 'package:flutter/material.dart';
import 'app_colors.dart';

/// أنماط النصوص والخطوط الموحدة للتطبيق (Typography Styles)
class AppStyles {
  // نمط العناوين الرئيسية الكبيرة (مثل "Welcome back" و "Stop music in")
  static TextStyle get font28Bold => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // نمط عناوين الأقسام الرئيسية (مثل "Recent", "All Tracks", "Playlists")
  static TextStyle get font22Bold => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // نمط عناوين الأشرطة العلوية (مثل "NOW PLAYING", "Equalizer", "Settings")
  static TextStyle get font18SemiBold => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  // نمط عناوين النوافذ المنبثقة البارزة
  static TextStyle get font18Bold => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  // نمط أسماء الأغاني في القوائم والبطاقات
  static TextStyle get font16SemiBold => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  // نمط نصوص متوسطة شبه عريضة (القوائم الفرعية والخيارات)
  static TextStyle get font14SemiBold => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  // نمط اسم الفنان أو النصوص الوصفية
  static TextStyle get font14Regular => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
  );

  // نمط نصوص الشروح والتفاصيل الصغيرة
  static TextStyle get font12Medium => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
  );

  // نمط أسماء الفنانين باللون البنفسجي أو الأزرق النيلي المميز في شاشة المشغل
  static TextStyle get font16Purple => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.isDark ? const Color(0xFF60A5FA) : AppColors.vibrantViolet,
  );

  // نمط الروابط السريعة مثل "See all"
  static const TextStyle font14Blue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );

  // نمط توقيت المقاطع الصوتية (مثل 1:17 و 4:03)
  static TextStyle get font12Muted => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.isDark ? AppColors.darkTextMuted : AppColors.textMuted,
  );

  // نمط الأزرار البارزة الكبيرة
  static const TextStyle font16ButtonWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  // نمط التسميات الصغيرة في المعادل الصوتي والمؤقت
  static TextStyle get font11Bold => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
    letterSpacing: 0.5,
  );
}
