import 'package:flutter/material.dart';
import '../../theming/app_colors.dart';

/// شريط تمرير مخصص (Custom Progress Slider)
/// يدعم التخصيص اللوني الكامل والشكل الدائري الناعم للكرة الدليلية
class CustomProgressBar extends StatelessWidget {
  final double value; // النسبة من 0.0 إلى 1.0
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color activeColor;
  final Color inactiveColor;
  final double trackHeight;
  final double thumbRadius;

  const CustomProgressBar({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.activeColor = AppColors.vibrantViolet,
    this.inactiveColor = AppColors.sliderInactive,
    this.trackHeight = 4.0,
    this.thumbRadius = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: trackHeight,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: thumbRadius,
          elevation: 2,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
        activeTrackColor: activeColor,
        inactiveTrackColor: inactiveColor,
        thumbColor: activeColor,
        overlayColor: activeColor.withAlpha(35),
      ),
      child: Slider(
        value: value.clamp(0.0, 1.0),
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}

