import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_styles.dart';
import '../../../core/shared/enums/playback_state.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../logic/now_playing_cubit.dart';
import '../logic/now_playing_state.dart';
import 'widgets/vinyl_artwork_card.dart';
import 'widgets/player_controls.dart';
import 'widgets/volume_slider.dart';

/// شاشة المشغل الموسيقي الشاملة (Now Playing Screen)
/// تطابق الصورة #1 بدقة وتتضمن الغلاف النيومورفيك وأزرار التحكم بالصوت والتشغيل
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down, size: 30, color: AppColors.textPrimaryColor(context)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'NOW PLAYING',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.textSecondaryColor(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, size: 26, color: AppColors.textPrimaryColor(context)),
            onPressed: () {
              // فتح قائمة الخيارات الإضافية
            },
          ),
        ],
      ),
      body: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        builder: (context, state) {
          final track = state.currentTrack;
          if (track == null) {
            return const Center(child: Text('لا يوجد مقطع صوتي نشط حالياً'));
          }

          final isPlaying = state.status == PlaybackStatus.playing;
          final totalMs = state.duration.inMilliseconds;
          final currentMs = state.position.inMilliseconds;
          final progressRatio = (totalMs > 0) ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // بطاقة غلاف الألبوم النيومورفيك
                    VinylArtworkCard(imageUrl: track.artworkUrl),

                    const SizedBox(height: 28),

                    // اسم الأغنية واسم الفنان
                    Text(
                      track.title,
                      style: AppStyles.font22Bold.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      track.artist,
                      style: AppStyles.font16Purple,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // شريط التقدم الصوتي المخصص
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4.5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: AppColors.isDark ? AppColors.primaryBlue : AppColors.sliderActivePurple,
                        thumbColor: AppColors.isDark ? AppColors.primaryBlue : AppColors.sliderActivePurple,
                        inactiveTrackColor: AppColors.isDark ? const Color(0xFF1E2538) : AppColors.sliderInactive,
                      ),
                      child: Slider(
                        value: progressRatio,
                        onChanged: (ratio) {
                          final targetMs = (ratio * totalMs).toInt();
                          context.read<NowPlayingCubit>().seekTo(Duration(milliseconds: targetMs));
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // توقيت البداية والمدة الكلية
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(state.position.toMinutesSeconds(), style: AppStyles.font12Muted),
                          Text(state.duration.toMinutesSeconds(), style: AppStyles.font12Muted),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // منصة أزرار التحكم في التشغيل
                    PlayerControls(
                      isPlaying: isPlaying,
                      isShuffle: state.isShuffleEnabled,
                      repeatMode: state.repeatMode,
                      onPlayPause: () => context.read<NowPlayingCubit>().togglePlayPause(),
                      onNext: () => context.read<NowPlayingCubit>().playNextTrack(),
                      onPrevious: () => context.read<NowPlayingCubit>().playPreviousTrack(),
                      onShuffleToggle: () => context.read<NowPlayingCubit>().toggleShuffle(),
                      onRepeatToggle: () => context.read<NowPlayingCubit>().toggleRepeatMode(),
                    ),

                    const SizedBox(height: 24),

                    // شريط التحكم بمستوى الصوت مع الأزرار الإضافية السفلية
                    VolumeSlider(
                      volume: state.volume,
                      onVolumeChanged: (vol) => context.read<NowPlayingCubit>().setVolume(vol),
                    ),

                    const SizedBox(height: 16),
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

