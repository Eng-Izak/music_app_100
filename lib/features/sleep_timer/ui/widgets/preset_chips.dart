import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';

/// خيارات الفترات المسبقة لمؤقت النوم (Quick Preset Chips)
/// تطابق أزرار (15m, 30m, 45m, 1h) في الصورة #6
class PresetChips extends StatelessWidget {
  final Duration selectedDuration;
  final ValueChanged<Duration> onSelect;

  const PresetChips({
    super.key,
    required this.selectedDuration,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الصف الأول: 15 دقيقة، 30 دقيقة، 45 دقيقة
        Row(
          children: [
            Expanded(
              child: _buildChip(
                label: '15m',
                duration: const Duration(minutes: 15),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildChip(
                label: '30m',
                duration: const Duration(minutes: 30),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildChip(
                label: '45m',
                duration: const Duration(minutes: 45),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // الصف الثاني: 1 ساعة كاملة
        SizedBox(
          width: double.infinity,
          child: _buildChip(
            label: '1h',
            duration: const Duration(hours: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildChip({required String label, required Duration duration}) {
    final isSelected = selectedDuration.inMinutes == duration.inMinutes;

    return GestureDetector(
      onTap: () => onSelect(duration),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSelected
              ? (AppColors.isDark ? const Color(0xFF3B1D66) : AppColors.primaryBlue)
              : (AppColors.isDark ? const Color(0xFF181524) : AppColors.cardWhite),
          borderRadius: BorderRadius.circular(26),
          border: isSelected && AppColors.isDark
              ? Border.all(color: const Color(0xFFA855F7), width: 1.5)
              : null,
          boxShadow: isSelected
              ? (AppColors.isDark ? AppColors.glowingPurpleShadow : AppColors.glowingBlueShadow)
              : (AppColors.isDark ? AppColors.darkShadow : AppColors.softShadow),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (AppColors.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

