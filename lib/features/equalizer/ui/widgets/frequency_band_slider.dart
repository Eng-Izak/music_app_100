import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_styles.dart';

/// مؤشر التردد الرأسي في المعادل الصوتي (Vertical Frequency Band Slider)
/// يطابق الأعمدة الرأسية الخمسة في الصورة #5 بدقة متناهية
class FrequencyBandSlider extends StatelessWidget {
  final String label;
  final double gainDb; // القيمة بالديسيبل من -12.0 إلى +12.0
  final bool isEnabled;
  final ValueChanged<double> onGainChanged;

  const FrequencyBandSlider({
    super.key,
    required this.label,
    required this.gainDb,
    this.isEnabled = true,
    required this.onGainChanged,
  });

  @override
  Widget build(BuildContext context) {
    // تحويل القيمة بالديسيبل (-12 إلى +12) إلى نسبة طبيعية بين 0.0 و 1.0
    // formula: ratio = (gainDb - (-12)) / (12 - (-12)) = (gainDb + 12) / 24
    final normalizedValue = ((gainDb + 12.0) / 24.0).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // تسمية الحد الأعلى (+12)
        const Text('+12', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        // شريط التمرير الرأسي المخصص
        SizedBox(
          height: 200,
          width: 32,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              if (!isEnabled) return;
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              // حساب الإزاحة الرأسية من الأسفل إلى الأعلى
              final localPos = details.localPosition.dy.clamp(0.0, 200.0);
              final newRatio = (1.0 - (localPos / 200.0)).clamp(0.0, 1.0);
              // تحويل النسبة مجدداً إلى ديسيبل: gainDb = (ratio * 24) - 12
              final newDb = (newRatio * 24.0) - 12.0;
              onGainChanged(double.parse(newDb.toStringAsFixed(1)));
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // المسار الكامل غير النشط (Track)
                Container(
                  width: 4.5,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.isDark ? const Color(0xFF2D283E) : AppColors.sliderInactive,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // المسار النشط الممتلئ باللون الأزرق من الأسفل إلى موضع المقبض
                Container(
                  width: 4.5,
                  height: 200 * normalizedValue,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? (AppColors.isDark ? const Color(0xFFA855F7) : AppColors.primaryBlue)
                        : AppColors.textSecondaryColor(context),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // المقبض الدائري الأبيض مع إطار ملون (Thumb)
                Positioned(
                  bottom: (200 * normalizedValue) - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: isEnabled
                            ? (AppColors.isDark ? const Color(0xFFA855F7) : AppColors.primaryBlue)
                            : AppColors.textSecondaryColor(context),
                        width: 2.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (AppColors.isDark ? const Color(0xFFA855F7) : AppColors.primaryBlue)
                              .withAlpha(isEnabled ? 90 : 20),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),
        // تسمية الحد الأدنى (-12)
        const Text('-12', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        // اسم التردد الصوتي (60Hz, 230Hz, ...)
        Text(
          label,
          style: AppStyles.font11Bold.copyWith(fontSize: 13),
        ),
      ],
    );
  }
}

