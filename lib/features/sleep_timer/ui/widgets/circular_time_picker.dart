import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';

/// منتقي الوقت الدائري (Circular Time Picker)
/// يطابق الدائرة المركزية بالصورة #6 مع قوسي الدوران وعرض الساعات والدقائق
class CircularTimePicker extends StatelessWidget {
  final int selectedHours;
  final int selectedMinutes;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;

  const CircularTimePicker({
    super.key,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.72;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // القوس الخارجي الأزرق الناعم
            CustomPaint(
              size: Size(size, size),
              painter: _TimerArcPainter(),
            ),

            // محتوى الساعات والدقائق
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // عمود الساعات (Hours Column)
                _buildTimeColumn(
                  label: 'HOURS',
                  prevValue: (selectedHours - 1 < 0) ? 0 : selectedHours - 1,
                  currentValue: selectedHours,
                  nextValue: selectedHours + 1,
                  onPrevTap: () => onHoursChanged((selectedHours - 1).clamp(0, 12)),
                  onNextTap: () => onHoursChanged((selectedHours + 1).clamp(0, 12)),
                ),

                const SizedBox(width: 16),

                // النقطتان الرأسيتان (:)
                const Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // عمود الدقائق (Minutes Column)
                _buildTimeColumn(
                  label: 'MINUTES',
                  prevValue: (selectedMinutes - 15 < 0) ? 0 : selectedMinutes - 15,
                  currentValue: selectedMinutes,
                  nextValue: (selectedMinutes + 15 > 59) ? 0 : selectedMinutes + 15,
                  onPrevTap: () => onMinutesChanged((selectedMinutes - 5).clamp(0, 59)),
                  onNextTap: () => onMinutesChanged((selectedMinutes + 5).clamp(0, 59)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn({
    required String label,
    required int prevValue,
    required int currentValue,
    required int nextValue,
    required VoidCallback onPrevTap,
    required VoidCallback onNextTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // القيمة السابقة
        GestureDetector(
          onTap: onPrevTap,
          child: Text(
            '$prevValue',
            style: const TextStyle(fontSize: 16, color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ),

        const SizedBox(height: 10),

        // القيمة الحالية داخل دائرة ملونة ناعمة
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.isDark ? const Color(0xFF1E2538) : const Color(0xFFDBEAFE),
          ),
          child: Center(
            child: Text(
              '$currentValue',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // القيمة التالية
        GestureDetector(
          onTap: onNextTap,
          child: Text(
            '$nextValue',
            style: const TextStyle(fontSize: 16, color: AppColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ),

        const SizedBox(height: 12),

        // تسمية HOURS أو MINUTES
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TimerArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;

    // مسار الدائرة الخفيف الخلفي
    final bgPaint = Paint()
      ..color = AppColors.isDark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // القوس المشع التزييني
    final arcPaint = Paint()
      ..color = AppColors.isDark ? const Color(0xFFA855F7) : const Color(0xFFBFDBFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    // رسم القوس من زاوية علوية
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.3,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

