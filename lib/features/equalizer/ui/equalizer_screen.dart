import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_styles.dart';
import '../../../core/shared/enums/equalizer_preset.dart';
import '../logic/equalizer_cubit.dart';
import '../logic/equalizer_state.dart';
import 'widgets/frequency_band_slider.dart';
import 'widgets/rotary_knob_widget.dart';
import '../../../core/shared/widgets/app_developer_footer.dart';

/// شاشة المعادل الصوتي (Equalizer #5)
/// متطابقة بيكسل ببيكسل مع الصورة #5 المرفقة
class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimaryColor(context)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text('Equalizer', style: AppStyles.font18SemiBold),
        actions: [
          // زر الطاقة الدائري الأزرق في أعلى اليمين
          BlocBuilder<EqualizerCubit, EqualizerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    context.read<EqualizerCubit>().togglePower();
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.isEnabled
                          ? (AppColors.isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF))
                          : (AppColors.isDark ? const Color(0xFF1E2538) : AppColors.surfaceMuted),
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      size: 22,
                      color: state.isEnabled
                          ? (AppColors.isDark ? const Color(0xFF60A5FA) : AppColors.primaryBlue)
                          : AppColors.textSecondaryColor(context),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<EqualizerCubit, EqualizerState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان النمط الصوتي (SOUND PRESET)
                    Text(
                      'SOUND PRESET',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textSecondaryColor(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // قائمة اختيار الأنماط المسبقة (Preset Dropdown)
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.getShadow(context),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<EqualizerPresetType>(
                          value: state.preset,
                          dropdownColor: AppColors.cardBg(context),
                          isExpanded: true,
                          icon: Icon(Icons.unfold_more, color: AppColors.textSecondaryColor(context)),
                          items: EqualizerPresetType.values.map((preset) {
                            return DropdownMenuItem<EqualizerPresetType>(
                              value: preset,
                              child: Text(
                                preset.displayName,
                                style: AppStyles.font16SemiBold,
                              ),
                            );
                          }).toList(),
                          onChanged: (newPreset) {
                            if (newPreset != null) {
                              context.read<EqualizerCubit>().selectPreset(newPreset);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // عنوان الترددات (Frequency Bands)
                    Text('Frequency Bands', style: AppStyles.font22Bold),

                    const SizedBox(height: 20),

                    // أعمدة الترددات الخمسة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: state.bandGains.entries.map((entry) {
                        return FrequencyBandSlider(
                          label: entry.key,
                          gainDb: entry.value,
                          isEnabled: state.isEnabled,
                          onGainChanged: (newGain) {
                            context.read<EqualizerCubit>().setBandGain(entry.key, newGain);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 36),

                    // الحاوية السفلية المرتفعة للقرصين الدوارين
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg(context),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: AppColors.getShadow(context),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RotaryKnobWidget(
                            title: 'Bass Boost',
                            value: state.bassBoost,
                            isEnabled: state.isEnabled,
                            onChanged: (val) {
                              context.read<EqualizerCubit>().setBassBoost(val);
                            },
                          ),
                          RotaryKnobWidget(
                            title: '3D Surround',
                            value: state.virtualizer,
                            isEnabled: state.isEnabled,
                            onChanged: (val) {
                              context.read<EqualizerCubit>().setVirtualizer(val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const AppDeveloperFooter(),
                    const SizedBox(height: 24),
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

