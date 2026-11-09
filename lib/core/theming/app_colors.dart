import 'package:flutter/material.dart';

/// فئة الألوان الخاصة بتطبيق BeatFlow الموسيقي
/// تحتوي على ثوابت الألوان الموحدة للوضعين الفاتح والداكن
class AppColors {
  /// حالة الثيم النشط (تُحدّث عند تغيير الإعدادات)
  static bool isDark = false;

  // الألوان الأساسية للتطبيق (Primary & Brand Accents)
  static const Color primaryBlue = Color(0xFF2979FF); // أزرق ساطع مستخدم في المشغل وزر الإضافة
  static const Color vibrantViolet = Color(0xFF8A2BE2); // بنفسجي نابض بالحياة
  static const Color neonIndigo = Color(0xFF6366F1); // نيلي نيون للإضاءات والتدرجات
  static const Color deepPurple = Color(0xFF9333EA); // بنفسجي غني لأزرار التشغيل

  // ألوان الوضع الفاتح (Light Palette)
  static const Color scaffoldBackground = Color(0xFFF8F9FD); // رمادي فاتح مائل للأبيض
  static const Color cardWhite = Colors.white; // أبيض ناصع للبطاقات المرتفعة
  static const Color surfaceMuted = Color(0xFFF1F3F9); // رمادي خفيف جداً للحاويات وحقول الإدخال
  static const Color dividerColor = Color(0xFFE5E7EB); // لون الفواصل والحدود الناعمة

  // ألوان الوضع الداكن الفاخر (Midnight Dark Palette - متطابق مع استايل الصور)
  static const Color darkScaffold = Color(0xFF0B0E17); // أسود كحلي عميق فاخر لخلفية الشاشات
  static const Color darkCard = Color(0xFF161D2D); // سليت كحلي داكن ناعم للبطاقات والحاويات
  static const Color darkSurface = Color(0xFF182032); // سطح داكن ناعم للحقول والأزرار غير النشطة
  static const Color darkDivider = Color(0xFF1F293D); // فواصل وحدود داكنة أنيقة
  static const Color darkScaffoldPurple = Color(0xFF0E0C15); // خلفية بنفسجية فاحمة لشاشتي المعادل والمؤقت
  static const Color darkCardPurple = Color(0xFF181524); // بطاقات بنفسجية داكنة لشاشتي المعادل والمؤقت

  // ألوان النصوص والعناوين (Typography Colors)
  static const Color textPrimary = Color(0xFF111827); // أسود داكن للعناوين بالوضع الفاتح
  static const Color textSecondary = Color(0xFF6B7280); // رمادي للنصوص الفرعية
  static const Color textMuted = Color(0xFF9CA3AF); // رمادي باهت للأرقام والوقت
  static const Color textWhite = Colors.white; // أبيض ناصع

  // نصوص الوضع الداكن
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // أبيض ناصع ساطع للعناوين في الوضع الداكن
  static const Color darkTextSecondary = Color(0xFF8E9AA8); // رمادي ناعم للنصوص الفرعية بالوضع الداكن
  static const Color darkTextMuted = Color(0xFF64748B); // رمادي متوسط للتوقيت والتفاصيل

  // ألوان حالة المشغل والمؤشرات (Controls & Indicators)
  static const Color sliderActive = Color(0xFF2979FF); // مؤشر التمرير النشط (أزرق)
  static const Color sliderActivePurple = Color(0xFFA855F7); // مؤشر التمرير البنفسجي
  static const Color sliderInactive = Color(0xFFE5E7EB); // مسار شريط التمرير غير النشط
  static const Color errorRed = Color(0xFFEF4444); // أحمر لأزرار تسجيل الخروج والأخطاء
  static const Color successGreen = Color(0xFF10B981); // أخضر للحالات الناجحة

  // التدرجات اللونية (Linear Gradients)
  static const LinearGradient favoritesGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE040FB),
      Color(0xFF7C4DFF),
    ],
  );

  static const LinearGradient blueButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
    ],
  );

  // ظلال ناعمة وتأثيرات الإضاءة (Soft Neumorphic & Elevation Shadows)
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF90A4AE).withAlpha(30),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get darkShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(90),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowingPurpleShadow => [
        BoxShadow(
          color: vibrantViolet.withAlpha(90),
          blurRadius: 25,
          spreadRadius: 4,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get glowingBlueShadow => [
        BoxShadow(
          color: primaryBlue.withAlpha(90),
          blurRadius: 25,
          spreadRadius: 4,
          offset: const Offset(0, 8),
        ),
      ];

  // دوال مساعدة لاسترجاع اللون المناسب بناءً على سياق الثيم النشط
  static Color scaffoldBg(BuildContext context) =>
      (isDark || Theme.of(context).brightness == Brightness.dark) ? darkScaffold : scaffoldBackground;

  static Color cardBg(BuildContext context) =>
      (isDark || Theme.of(context).brightness == Brightness.dark) ? darkCard : cardWhite;

  static Color textPrimaryColor(BuildContext context) =>
      (isDark || Theme.of(context).brightness == Brightness.dark) ? darkTextPrimary : textPrimary;

  static Color textSecondaryColor(BuildContext context) =>
      (isDark || Theme.of(context).brightness == Brightness.dark) ? darkTextSecondary : textSecondary;

  static Color divider(BuildContext context) =>
      (isDark || Theme.of(context).brightness == Brightness.dark) ? darkDivider : dividerColor;

  static List<BoxShadow> getShadow(BuildContext context) =>
      (isDark || Theme.of(context).brightness == Brightness.dark) ? darkShadow : softShadow;
}
