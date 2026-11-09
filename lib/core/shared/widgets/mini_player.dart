import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theming/app_colors.dart';
import '../../theming/app_styles.dart';
import '../../shared/enums/playback_state.dart';
import '../../../features/now_playing/logic/now_playing_cubit.dart';
import '../../../features/now_playing/logic/now_playing_state.dart';
import '../../routing/routes.dart';
import '../../utils/constants/assets_keys.dart';

/// المشغل المصغر العائم (Floating Mini Player)
/// يظهر فوق شريط التنقل السفلي مباشرة كما في الصور المرفقة
/// يعرض صورة المقطع، العنوان، الفنان، وأزرار التحكم بالتشغيل، بالإضافة لشريط تقدم سفلي نحيف
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NowPlayingCubit, NowPlayingState>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (!state.isMiniPlayerVisible || track == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = state.status == PlaybackStatus.playing;
        // حساب نسبة التقدم الصوتي (بين 0.0 و 1.0)
        final progressRatio = (state.duration.inMilliseconds > 0)
            ? (state.position.inMilliseconds / state.duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return Dismissible(
          key: ValueKey('mini_player_${track.id}'),
          direction: isPlaying ? DismissDirection.none : DismissDirection.horizontal,
          onDismissed: (_) {
            context.read<NowPlayingCubit>().dismissMiniPlayer();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
            onTap: () {
              // فتح شاشة التشغيل الكاملة (Now Playing Screen)
              Navigator.of(context).pushNamed(Routes.nowPlaying);
            },
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.cardBg(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.getShadow(context),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          // أيقونة النغمة الموحدة المصغرة
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              AssetsKeys.musicNoteIcon,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // تفاصيل المقطع الصوتي (العنوان والفنان)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  style: AppStyles.font16SemiBold.copyWith(
                                    fontSize: 14,
                                    color: AppColors.textPrimaryColor(context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  track.artist,
                                  style: AppStyles.font14Regular.copyWith(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryColor(context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // زر التخطي للخلف (Previous)
                          IconButton(
                            icon: Icon(Icons.skip_previous, size: 22, color: AppColors.textPrimaryColor(context)),
                            onPressed: () {
                              context.read<NowPlayingCubit>().playPreviousTrack();
                            },
                          ),
                          // زر التشغيل والإيقاف الدائري الأزرق
                          GestureDetector(
                            onTap: () {
                              context.read<NowPlayingCubit>().togglePlayPause();
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryBlue,
                                boxShadow: AppColors.isDark
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryBlue.withAlpha(120),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          // زر التخطي للأمام (Next)
                          IconButton(
                            icon: Icon(Icons.skip_next, size: 22, color: AppColors.textPrimaryColor(context)),
                            onPressed: () {
                              context.read<NowPlayingCubit>().playNextTrack();
                            },
                          ),
                        ],
                      ),
                    ),
                    // شريط التقدم النحيف الأزرق في أسفل البطاقة
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 2.5,
                        backgroundColor: AppColors.isDark ? const Color(0xFF1E2538) : Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    );
  }
}

