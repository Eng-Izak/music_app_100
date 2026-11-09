import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_styles.dart';

/// عنصر التفضيل التفاعلي المطور كبطاقة مستقلة ناعمة (Preferences Tile Card)
/// مطابق تماماً لستايل الصورة المرفقة للوضع الليلي
class PreferencesTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PreferencesTile({
    super.key,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // لون خلفية الأيقونة: بنفسجي/نيلي داكن فاخر في الوضع الليلي أو أزرق فاتح في النهاري
    final effectiveIconBg = iconBackgroundColor ??
        (AppColors.isDark ? const Color(0xFF222146) : const Color(0xFFEFF6FF));
    final effectiveIconColor = iconColor ?? AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: AppColors.isDark ? const Color(0xFF18192E) : AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.isDark
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isSwitch ? () => onSwitchChanged?.call(!switchValue) : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
            child: Row(
              children: [
                // حاوية الأيقونة المربعة ذات الزوايا الدائرية
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: effectiveIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: effectiveIconColor, size: 22),
                ),

                const SizedBox(width: 14),

                // عنوان التفضيل والوصف الفرعي إن وجد
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: AppStyles.font16SemiBold.copyWith(
                          fontSize: 15,
                          color: titleColor ??
                              (AppColors.isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.isDark
                                ? const Color(0xFF8E9AA8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // مفتاح التبديل أو الأيقونة التابعة
                if (isSwitch)
                  Switch.adaptive(
                    value: switchValue,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryBlue,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.isDark
                        ? const Color(0xFF2E3048)
                        : const Color(0xFFE5E7EB),
                    onChanged: onSwitchChanged,
                  )
                else if (trailing != null)
                  trailing!
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: AppColors.isDark
                        ? const Color(0xFF64748B)
                        : AppColors.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

