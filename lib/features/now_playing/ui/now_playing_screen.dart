import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_styles.dart';
import '../../../core/shared/enums/playback_state.dart';
import '../../../core/shared/enums/repeat_mode.dart';
import '../../../core/shared/models/track_model.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../core/routing/routes.dart';
import '../../playlists/logic/playlists_cubit.dart';
import '../../playlists/logic/playlists_state.dart';
import '../../settings/logic/settings_cubit.dart';
import '../logic/now_playing_cubit.dart';
import '../logic/now_playing_state.dart';
import 'widgets/vinyl_artwork_card.dart';
import 'widgets/player_controls.dart';
import 'widgets/volume_slider.dart';

/// شاشة المشغل الموسيقي الشاملة (Now Playing Screen)
/// تدعم وظائف الأزرار الستة المنطقية الاحترافية:
/// 1. زر الخيارات العلوية (3 نقاط): خيارات المقطع، التفضيل، القوائم، المعادل، المؤقت، التفاصيل
/// 2. زر الخلط العشوائي (Shuffle): تفعيل/تعطيل الترتيب العشوائي مع مؤشر مرئي وتنبيه
/// 3. زر التكرار (Repeat): التبديل بين تكرار الكل / تكرار المقطع / إيقاف التكرار
/// 4. زر مخرج الصوت (Devices): عرض المخرج الصوتي والتحكم السريع بمستوى الصوت واختصار المعادل
/// 5. زر المشاركة (Share): مشاركة بيانات المقطع عبر واجهة أندرويد الأصلية أو نسخها
/// 6. زر قائمة الانتظار (Queue): عرض المقاطع القادمة مع إمكانية التشغيل والحذف
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  static const MethodChannel _shareChannel = MethodChannel('com.example.music_app_100/share');

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsCubit>().state.isArabic;

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
          isAr ? 'قيد التشغيل الآن' : 'NOW PLAYING',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.textSecondaryColor(context),
          ),
        ),
        actions: [
          BlocBuilder<NowPlayingCubit, NowPlayingState>(
            builder: (context, state) {
              return IconButton(
                tooltip: isAr ? 'خيارات المقطع' : 'Track Options',
                icon: Icon(Icons.more_horiz, size: 26, color: AppColors.textPrimaryColor(context)),
                onPressed: () {
                  final track = state.currentTrack;
                  if (track != null) {
                    _showTrackOptionsSheet(context, track, state, isAr);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NowPlayingCubit, NowPlayingState>(
        builder: (context, state) {
          final track = state.currentTrack;
          if (track == null) {
            return Center(
              child: Text(
                isAr ? 'لا يوجد مقطع صوتي نشط حالياً' : 'No track currently active',
                style: AppStyles.font16Regular,
              ),
            );
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

                    // بطاقة غلاف الألبوم
                    VinylArtworkCard(imageUrl: track.artworkUrl),

                    const SizedBox(height: 28),

                    // اسم الأغنية واسم الفنان
                    Text(
                      track.title,
                      style: AppStyles.font22Bold.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      track.artist,
                      style: AppStyles.font16Purple,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

                    // منصة أزرار التحكم في التشغيل (الخلط، السابق، التشغيل/الإيقاف، التالي، التكرار)
                    PlayerControls(
                      isPlaying: isPlaying,
                      isShuffle: state.isShuffleEnabled,
                      repeatMode: state.repeatMode,
                      onPlayPause: () => context.read<NowPlayingCubit>().togglePlayPause(),
                      onNext: () => context.read<NowPlayingCubit>().playNextTrack(),
                      onPrevious: () => context.read<NowPlayingCubit>().playPreviousTrack(),
                      onShuffleToggle: () {
                        context.read<NowPlayingCubit>().toggleShuffle();
                        final willBeEnabled = !state.isShuffleEnabled;
                        _showFeedback(
                          context,
                          willBeEnabled
                              ? (isAr ? 'تم تفعيل الوضع العشوائي 🔀' : 'Shuffle Enabled 🔀')
                              : (isAr ? 'تم إيقاف الوضع العشوائي' : 'Shuffle Disabled'),
                        );
                      },
                      onRepeatToggle: () {
                        final current = state.repeatMode;
                        context.read<NowPlayingCubit>().toggleRepeatMode();
                        String message;
                        switch (current) {
                          case AppRepeatMode.off:
                            message = isAr ? 'تكرار قائمة التشغيل كاملة 🔁' : 'Repeat All 🔁';
                            break;
                          case AppRepeatMode.repeatAll:
                            message = isAr ? 'تكرار المقطع الحالي فقط 🔂' : 'Repeat Current Track 🔂';
                            break;
                          case AppRepeatMode.repeatOne:
                            message = isAr ? 'تم إيقاف التكرار' : 'Repeat Off';
                            break;
                        }
                        _showFeedback(context, message);
                      },
                    ),

                    const SizedBox(height: 24),

                    // شريط التحكم بمستوى الصوت مع أزرار المهام السفلية (الأجهزة، المشاركة، وقائمة الانتظار)
                    VolumeSlider(
                      volume: state.volume,
                      onVolumeChanged: (vol) => context.read<NowPlayingCubit>().setVolume(vol),
                      onDevicesTap: () => _showAudioOutputSheet(context, isAr),
                      onShareTap: () => _shareTrack(context, track, isAr),
                      onQueueTap: () => _showQueueBottomSheet(context, state, isAr),
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

  /// إظهار قائمة خيارات المقطع الصوتي (الزر العلوي بثلاث نقاط)
  void _showTrackOptionsSheet(BuildContext context, TrackModel track, NowPlayingState state, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شريط مقبض السحب
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ترويسة تفاصيل المقطع الصوتي
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: track.artworkUrl.isNotEmpty
                              ? Image.asset(track.artworkUrl, width: 48, height: 48, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail())
                              : _buildFallbackThumbnail(),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(track.title, style: AppStyles.font16SemiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(track.artist, style: AppStyles.font12Medium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Divider(color: AppColors.divider(context)),

                  // 1. إضافة أو إزالة من المفضلة
                  _buildOptionItem(
                    context: context,
                    icon: track.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: track.isFavorite ? Colors.redAccent : AppColors.textPrimaryColor(context),
                    title: track.isFavorite
                        ? (isAr ? 'إزالة من المفضلة' : 'Remove from Favorites')
                        : (isAr ? 'إضافة إلى المفضلة' : 'Add to Favorites'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.read<NowPlayingCubit>().toggleFavorite(track);
                      _showFeedback(
                        context,
                        track.isFavorite
                            ? (isAr ? 'تمت الإزالة من المفضلة' : 'Removed from favorites')
                            : (isAr ? 'تمت الإضافة إلى المفضلة ❤️' : 'Added to favorites ❤️'),
                      );
                    },
                  ),

                  // 2. إضافة إلى قائمة تشغيل
                  _buildOptionItem(
                    context: context,
                    icon: Icons.playlist_add_rounded,
                    title: isAr ? 'إضافة إلى قائمة تشغيل' : 'Add to Playlist',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showAddToPlaylistDialog(context, track, isAr);
                    },
                  ),

                  // 3. المعادل الصوتي
                  _buildOptionItem(
                    context: context,
                    icon: Icons.tune_rounded,
                    title: isAr ? 'المعادل الصوتي ومضخم الصوت' : 'Equalizer & Bass Boost',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, Routes.equalizer);
                    },
                  ),

                  // 4. مؤقت النوم
                  _buildOptionItem(
                    context: context,
                    icon: Icons.timer_outlined,
                    title: isAr ? 'مؤقت إيقاف الموسيقى (Sleep Timer)' : 'Sleep Timer',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, Routes.sleepTimer);
                    },
                  ),

                  // 5. مشاركة المقطع
                  _buildOptionItem(
                    context: context,
                    icon: Icons.share_outlined,
                    title: isAr ? 'مشاركة المقطع' : 'Share Track',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _shareTrack(context, track, isAr);
                    },
                  ),

                  // 6. تفاصيل وبيانات المقطع
                  _buildOptionItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: isAr ? 'معلومات وتفاصيل المقطع الصوتي' : 'Track Information',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showTrackDetailsDialog(context, track, isAr);
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// إظهار حوار اختيار قائمة التشغيل
  void _showAddToPlaylistDialog(BuildContext context, TrackModel track, bool isAr) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return BlocBuilder<PlaylistsCubit, PlaylistsState>(
          builder: (context, playlistsState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isAr ? 'إضافة إلى قائمة تشغيل' : 'Add to Playlist',
                style: AppStyles.font18Bold,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: playlistsState.playlists.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          isAr
                              ? 'لا توجد قوائم تشغيل حالياً، يرجى إنشاء قائمة أولاً من تبويب القوائم.'
                              : 'No playlists found. Create one from the Playlists tab.',
                          style: AppStyles.font14Regular,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: playlistsState.playlists.length,
                        separatorBuilder: (_, _) => Divider(color: AppColors.divider(context), height: 1),
                        itemBuilder: (context, idx) {
                          final playlist = playlistsState.playlists[idx];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.queue_music_rounded, color: AppColors.primaryBlue, size: 20),
                            ),
                            title: Text(playlist.title, style: AppStyles.font14SemiBold),
                            subtitle: Text(
                              isAr ? '${playlist.trackCount} مقطع' : '${playlist.trackCount} tracks',
                              style: AppStyles.font12Medium,
                            ),
                            onTap: () {
                              context.read<PlaylistsCubit>().addTrackToPlaylist(playlist.id, track);
                              Navigator.pop(dialogCtx);
                              _showFeedback(
                                context,
                                isAr
                                    ? 'تمت إضافة المقطع إلى "${playlist.title}"'
                                    : 'Added to "${playlist.title}"',
                              );
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    isAr ? 'إلغاء' : 'Cancel',
                    style: TextStyle(color: AppColors.textSecondaryColor(dialogCtx)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// إظهار تفاصيل وبيانات الملف الصوتي
  void _showTrackDetailsDialog(BuildContext context, TrackModel track, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isAr ? 'تفاصيل المقطع الصوتي' : 'Track Information',
            style: AppStyles.font18Bold,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(isAr ? 'اسم الأغنية:' : 'Title:', track.title),
                _buildDetailRow(isAr ? 'اسم الفنان:' : 'Artist:', track.artist),
                if (track.album.isNotEmpty)
                  _buildDetailRow(isAr ? 'الألبوم:' : 'Album:', track.album),
                _buildDetailRow(isAr ? 'المدة الزمنية:' : 'Duration:', track.duration.toMinutesSeconds()),
                if (track.audioUrl.isNotEmpty)
                  _buildDetailRow(isAr ? 'مسار الملف:' : 'File Path:', track.audioUrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isAr ? 'حسناً' : 'OK',
                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  /// إظهار نافذة التحكم بمخرج الصوت ومستوى الصوت (زر الأجهزة السفلي - اليسار)
  void _showAudioOutputSheet(BuildContext context, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return BlocBuilder<NowPlayingCubit, NowPlayingState>(
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // مقبض السحب
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // عنوان النافذة
                    Row(
                      children: [
                        const Icon(Icons.devices, color: AppColors.primaryBlue, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          isAr ? 'مخرج الصوت والأجهزة المتصلة' : 'Audio Output & Devices',
                          style: AppStyles.font18Bold,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // بطاقة حالة المخرج الصوتي الحالي
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volume_up_rounded, color: AppColors.primaryBlue, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'سماعة الهاتف / مكبر الصوت' : 'Device Speaker / Audio Output',
                                  style: AppStyles.font14SemiBold,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr ? 'المخرج الصوتي يعمل بنجاح' : 'Audio routing active',
                                  style: AppStyles.font12Muted,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isAr ? 'نشط' : 'Active',
                              style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // اختصار الدخول للمعادل الصوتي
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, Routes.equalizer);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBg(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (AppColors.isDark ? AppColors.primaryBlue : AppColors.vibrantViolet).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: AppColors.isDark ? AppColors.primaryBlue : AppColors.vibrantViolet,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'المعادل الصوتي ومؤثرات Bass' : 'Equalizer & Bass Boost',
                                    style: AppStyles.font14SemiBold,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAr ? 'تخصيص الترددات والمؤثرات الصوتية' : 'Tune frequencies & audio effects',
                                    style: AppStyles.font12Muted,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondaryColor(context)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // شريط ضبط الصوت الداخلي
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_mute, size: 20),
                          onPressed: () => context.read<NowPlayingCubit>().setVolume(0.0),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                              activeTrackColor: AppColors.primaryBlue,
                              thumbColor: AppColors.primaryBlue,
                            ),
                            child: Slider(
                              value: state.volume.clamp(0.0, 1.0),
                              onChanged: (vol) => context.read<NowPlayingCubit>().setVolume(vol),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 20),
                          onPressed: () => context.read<NowPlayingCubit>().setVolume(1.0),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// تنفيذ مشاركة المقطع الصوتي (زر المشاركة السفلي - المنتصف)
  Future<void> _shareTrack(BuildContext context, TrackModel track, bool isAr) async {
    final shareText = '🎵 ${track.title} - ${track.artist}\nعبر تطبيق Music Player';

    try {
      final success = await _shareChannel.invokeMethod<bool>('shareTrack', {
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
      });

      if (success != true) {
        // Fallback إلى الحافظة
        await Clipboard.setData(ClipboardData(text: shareText));
        if (context.mounted) {
          _showFeedback(context, isAr ? 'تم نسخ معلومات المقطع الصوتي للمشاركة' : 'Track info copied to clipboard');
        }
      }
    } catch (_) {
      // Fallback مباشر للحافظة في حالة أي استثناء
      await Clipboard.setData(ClipboardData(text: shareText));
      if (context.mounted) {
        _showFeedback(context, isAr ? 'تم نسخ معلومات المقطع للمشاركة 📋' : 'Track info copied to clipboard 📋');
      }
    }
  }

  /// إظهار قائمة الانتظار الحالية (زر القائمة السفلي - اليمين)
  void _showQueueBottomSheet(BuildContext context, NowPlayingState state, bool isAr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return BlocBuilder<NowPlayingCubit, NowPlayingState>(
          builder: (context, liveState) {
            final queue = liveState.queue;
            final currentId = liveState.currentTrack?.id;

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // مقبض السحب
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.divider(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ترويسة القائمة
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.queue_music_rounded, color: AppColors.primaryBlue, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  isAr ? 'قائمة التشغيل الحالية' : 'Current Queue',
                                  style: AppStyles.font18Bold,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isAr ? '${queue.length} مقطع' : '${queue.length} tracks',
                                style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      Divider(color: AppColors.divider(context)),

                      // محتوى القائمة
                      Expanded(
                        child: queue.isEmpty
                            ? Center(
                                child: Text(
                                  isAr ? 'قائمة الانتظار فارغة حالياً' : 'Queue is empty',
                                  style: AppStyles.font14Regular,
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: queue.length,
                                itemBuilder: (context, index) {
                                  final item = queue[index];
                                  final isCurrent = item.id == currentId;

                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? AppColors.primaryBlue.withValues(alpha: 0.12)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isCurrent
                                          ? Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4))
                                          : null,
                                    ),
                                    child: ListTile(
                                      leading: isCurrent
                                          ? const Icon(Icons.play_circle_filled_rounded, color: AppColors.primaryBlue, size: 28)
                                          : Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: AppColors.textSecondaryColor(context),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      title: Text(
                                        item.title,
                                        style: AppStyles.font14SemiBold.copyWith(
                                          color: isCurrent ? AppColors.primaryBlue : AppColors.textPrimaryColor(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        item.artist,
                                        style: AppStyles.font12Medium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item.duration.toMinutesSeconds(),
                                            style: AppStyles.font12Muted,
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 18),
                                            color: AppColors.textSecondaryColor(context),
                                            tooltip: isAr ? 'إزالة من القائمة' : 'Remove',
                                            onPressed: () {
                                              context.read<NowPlayingCubit>().removeTrackFromQueue(item.id);
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        context.read<NowPlayingCubit>().playOrToggleTrack(item);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// مساعد بناء عنصر خيار في القائمة
  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimaryColor(context), size: 22),
      title: Text(title, style: AppStyles.font14SemiBold),
      onTap: onTap,
    );
  }

  /// مساعد بناء سطر التفاصيل في حوار المعلومات
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  /// مصغرة افتراضية لغلاف الألبوم
  Widget _buildFallbackThumbnail() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.primaryBlue.withValues(alpha: 0.15),
      child: const Icon(Icons.music_note, color: AppColors.primaryBlue, size: 24),
    );
  }

  /// إظهار رسالة توضيحية سريعة (SnackBar)
  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
