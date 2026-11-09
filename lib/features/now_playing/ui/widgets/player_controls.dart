import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/enums/repeat_mode.dart';

/// منصة أزرار التحكم في التشغيل (Main Playback Controls Dock)
/// تضم أزرار التبديل العشوائي، المقطع السابق، الزر الدائري البنفسجي الرئيسي، المقطع التالي، والتكرار
class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffle;
  final AppRepeatMode repeatMode;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShuffleToggle;
  final VoidCallback onRepeatToggle;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onShuffleToggle,
    required this.onRepeatToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر التشغيل العشوائي (Shuffle)
          IconButton(
            icon: Icon(
              Icons.shuffle,
              size: 24,
              color: isShuffle
                  ? (AppColors.isDark ? AppColors.primaryBlue : AppColors.vibrantViolet)
                  : AppColors.textSecondaryColor(context),
            ),
            onPressed: onShuffleToggle,
          ),

          // زر المقطع السابق (Previous Track)
          IconButton(
            icon: Icon(
              Icons.skip_previous,
              size: 30,
              color: AppColors.textPrimaryColor(context),
            ),
            onPressed: onPrevious,
          ),

          // زر التشغيل / الإيقاف المؤقت البارز المتوهج
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.isDark
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B82F6), // أزرق ساطع
                          Color(0xFF1D4ED8), // أزرق ملكي داكن
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB026FF), // بنفسجي مشع
                          Color(0xFF8A2BE2), // بنفسجي نابض
                        ],
                      ),
                boxShadow: AppColors.isDark ? AppColors.glowingBlueShadow : AppColors.glowingPurpleShadow,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),

          // زر المقطع التالي (Next Track)
          IconButton(
            icon: Icon(
              Icons.skip_next,
              size: 30,
              color: AppColors.textPrimaryColor(context),
            ),
            onPressed: onNext,
          ),

          // زر التكرار (Repeat Mode)
          IconButton(
            icon: Icon(
              repeatMode == AppRepeatMode.repeatOne
                  ? Icons.repeat_one
                  : Icons.repeat,
              size: 24,
              color: repeatMode != AppRepeatMode.off
                  ? (AppColors.isDark ? AppColors.primaryBlue : AppColors.vibrantViolet)
                  : AppColors.textSecondaryColor(context),
            ),
            onPressed: onRepeatToggle,
          ),
        ],
      ),
    );
  }
}

