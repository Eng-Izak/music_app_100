import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_styles.dart';
import '../logic/sleep_timer_cubit.dart';
import '../logic/sleep_timer_state.dart';
import 'widgets/circular_time_picker.dart';
import 'widgets/preset_chips.dart';

/// شاشة مؤقت النوم وإيقاف الموسيقى (SleepTimerScreen / PlayingTimer #6)
/// مطابقة تماماً للصورة #6 المرفقة
class SleepTimerScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const SleepTimerScreen({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Sleep Timer', style: AppStyles.font18SemiBold),
      ),
      body: BlocBuilder<SleepTimerCubit, SleepTimerState>(
        builder: (context, state) {
          final isRunning = state.status == SleepTimerStatus.running;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 100.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // عنوان الشاشة الرئيسي
                    Text('Stop music in', style: AppStyles.font28Bold),
                    const SizedBox(height: 6),
                    Text(
                      'Your playback will fade out naturally',
                      style: AppStyles.font14Regular,
                    ),

                    const SizedBox(height: 28),

                    // منتقي الوقت الدائري
                    CircularTimePicker(
                      selectedHours: state.selectedDuration.inHours,
                      selectedMinutes: state.selectedDuration.inMinutes % 60,
                      onHoursChanged: (h) => context.read<SleepTimerCubit>().updateDuration(hours: h),
                      onMinutesChanged: (m) => context.read<SleepTimerCubit>().updateDuration(minutes: m),
                    ),

                    const SizedBox(height: 28),

                    // عنوان الخيارات السريعة
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'QUICK PRESETS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondaryColor(context),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // أزرار الفترات المسبقة (15m, 30m, 45m, 1h)
                    PresetChips(
                      selectedDuration: state.selectedDuration,
                      onSelect: (dur) => context.read<SleepTimerCubit>().selectPresetDuration(dur),
                    ),

                    const SizedBox(height: 28),

                    // نص توضيح موعد إيقاف الموسيقى (Music will stop at 11:30 PM)
                    RichText(
                      text: TextSpan(
                        text: 'Music will stop at ',
                        style: TextStyle(fontSize: 15, color: AppColors.textPrimaryColor(context)),
                        children: [
                          TextSpan(
                            text: state.targetStopTime,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر بدء / إيقاف المؤقت الأزرق البارز
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRunning ? AppColors.errorRed : AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 6,
                          shadowColor: isRunning
                              ? AppColors.errorRed.withAlpha(90)
                              : AppColors.primaryBlue.withAlpha(90),
                        ),
                        onPressed: () {
                          if (isRunning) {
                            context.read<SleepTimerCubit>().cancelTimer();
                          } else {
                            context.read<SleepTimerCubit>().startTimer();
                          }
                        },
                        icon: Icon(
                          isRunning ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          isRunning ? 'Cancel Timer' : 'Start Timer',
                          style: AppStyles.font16ButtonWhite,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

