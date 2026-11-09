import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_styles.dart';

/// قرص دوار تحكمي في المعادل الصوتي (Rotary Knob Dial)
/// يعرض مؤشر دائري أنيق مع نقطة زرقاء ونسبة مئوية (مثل 65% للجهير و 25% للصوت المحيطي)
class RotaryKnobWidget extends StatelessWidget {
  final String title;
  final double value; // النسبة من 0.0 إلى 1.0
  final bool isEnabled;
  final ValueChanged<double> onChanged;

  const RotaryKnobWidget({
    super.key,
    required this.title,
    required this.value,
    this.isEnabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // القرص الدائري التفاعلي
        GestureDetector(
          onPanUpdate: (details) {
            if (!isEnabled) return;
            // حساب الزاوية بناءً على موضع السحب نسبة لمركز القرص
            final RenderBox box = context.findRenderObject() as RenderBox;
            final center = Offset(box.size.width / 2, 50);
            final pos = details.localPosition;
            final dx = pos.dx - center.dx;
            final dy = pos.dy - center.dy;

            // حساب الزاوية بالراديان
            double angle = math.atan2(dy, dx);
            // تحويل الزاوية إلى نسبة مئوية سلسة
            double normalized = (angle + math.pi) / (2 * math.pi);
            onChanged(normalized.clamp(0.0, 1.0));
          },
          child: SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _KnobPainter(value: value, isEnabled: isEnabled),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // عنوان القرص (Bass Boost / 3D Surround)
        Text(
          title,
          style: AppStyles.font16SemiBold.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 2),

        // النسبة المئوية بلون أزرق ساطع
        Text(
          '$percentage%',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }
}

class _KnobPainter extends CustomPainter {
  final double value;
  final bool isEnabled;

  _KnobPainter({required this.value, required this.isEnabled});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;

    // رسم الدائرة الخارجية الناعمة
    final outerRingPaint = Paint()
      ..color = AppColors.isDark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 4, outerRingPaint);

    // رسم الدائرة الداخلية
    final innerCirclePaint = Paint()
      ..color = AppColors.isDark ? const Color(0xFF141A28) : Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    canvas.drawCircle(center, radius - 2, innerCirclePaint);

    // رسم الإطار الدائري الخفيف
    final borderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // حساب موضع النقطة الدليلية (Indicator Dot)
    // الزاوية تبدأ من -90 درجة + (value * 360)
    final angle = (-math.pi / 2) + (value * 2 * math.pi);
    final dotRadius = radius - 16;
    final dotCenter = Offset(
      center.dx + dotRadius * math.cos(angle),
      center.dy + dotRadius * math.sin(angle),
    );

    // رسم النقطة الدليلية الزرقاء المشعة
    final dotPaint = Paint()
      ..color = isEnabled ? AppColors.primaryBlue : AppColors.textMuted
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, 4.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _KnobPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.isEnabled != isEnabled;
  }
}

