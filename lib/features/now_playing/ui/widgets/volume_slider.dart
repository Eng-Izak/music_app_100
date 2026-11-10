import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';

/// شريط التحكم بمستوى الصوت مع أزرار الإجراءات الإضافية (Volume Slider & Bottom Dock)
/// مطابق للقسم السفلي في شاشة المشغل بالصورة #1
class VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback? onDevicesTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onQueueTap;

  const VolumeSlider({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
    this.onDevicesTap,
    this.onShareTap,
    this.onQueueTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // شريط الصوت محاطاً بأيقونات مكبر الصوت
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Icon(
                Icons.volume_down,
                size: 20,
                color: AppColors.textSecondaryColor(context),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3.5,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 0.0, // تصميم بدون كرة بارزة كما في الصورة
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: AppColors.isDark ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                    inactiveTrackColor: AppColors.isDark ? const Color(0xFF1E2538) : AppColors.sliderInactive,
                  ),
                  child: Slider(
                    value: volume.clamp(0.0, 1.0),
                    onChanged: onVolumeChanged,
                  ),
                ),
              ),
              Icon(
                Icons.volume_up,
                size: 20,
                color: AppColors.textSecondaryColor(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // أزرار المهام السفلية الثلاثة: الأجهزة، المشاركة، وقائمة الانتظار
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'مخرج الصوت',
                icon: Icon(Icons.devices, size: 24, color: AppColors.textSecondaryColor(context)),
                onPressed: onDevicesTap,
              ),
              IconButton(
                tooltip: 'مشاركة المقطع',
                icon: Icon(Icons.share_outlined, size: 24, color: AppColors.textSecondaryColor(context)),
                onPressed: onShareTap,
              ),
              IconButton(
                tooltip: 'قائمة الانتظار الحالية',
                icon: Icon(
                  Icons.queue_music,
                  size: 24,
                  color: AppColors.isDark ? const Color(0xFF60A5FA) : const Color(0xFFC084FC),
                ),
                onPressed: onQueueTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

