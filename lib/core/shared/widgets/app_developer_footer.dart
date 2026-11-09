import 'package:flutter/material.dart';
import '../../theming/app_colors.dart';

/// تذييل حقوق المصمم والمطور (Developer & Designer Credit Footer)
/// مطابق للتصميم المرفق: الجهة اليسرى باللغة الإنجليزية والجهة اليمنى باللغة العربية
/// متناسق مع الوضعين الداكن (Dark) والفاتح (Light)
class AppDeveloperFooter extends StatelessWidget {
  final bool showDivider;
  final EdgeInsetsGeometry padding;

  const AppDeveloperFooter({
    super.key,
    this.showDivider = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark || Theme.of(context).brightness == Brightness.dark;

    // ألوان النصوص المتناسقة مع الثيم
    final subtitleColor = isDark
        ? const Color(0xFF8E95AA)
        : const Color(0xFF788292);

    final nameColor = isDark
        ? const Color(0xFFF1C87D) // لون ذهبي هادئ وأنيق للوضع الليلي
        : const Color(0xFF9E722C); // لون برونزي ذهبي واضح للوضع الفاتح

    final dividerColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(18);

    return Directionality(
      // تثبيت الاتجاه LTR لضمان وجود النص الإنجليزي باليسار والعربي باليمين دوماً
      textDirection: TextDirection.ltr,
      child: Container(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDivider) ...[
              Divider(
                height: 1,
                thickness: 0.8,
                color: dividerColor,
              ),
              const SizedBox(height: 6),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // الجهة اليسرى: DESIGNED & DEVELOPED BY - Eng.Izak Rammah
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DESIGNED & DEVELOPED BY',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Eng.Izak Rammah',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: nameColor,
                      ),
                    ),
                  ],
                ),

                // الجهة اليمنى: مصمم ومطور التطبيق - م.إسحاق رماح
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مصمم ومطور التطبيق',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'م.إسحاق رماح',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: nameColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


