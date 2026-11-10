import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_styles.dart';
import '../../../core/shared/models/playlist_model.dart';
import '../../../core/shared/models/track_model.dart';
import '../../../core/shared/enums/playback_state.dart';
import '../../../core/shared/widgets/mini_player.dart';
import '../../../core/shared/widgets/app_developer_footer.dart';
import '../../../core/utils/constants/assets_keys.dart';
import '../../now_playing/logic/now_playing_cubit.dart';
import '../../now_playing/logic/now_playing_state.dart';
import '../../settings/logic/settings_cubit.dart';
import '../logic/playlists_cubit.dart';
import '../logic/playlists_state.dart';

/// شاشة تفاصيل ومحتوى قائمة التشغيل (Playlist Details Screen)
/// تطابق الصورة #5 بدقة متناهية مع البانر التدرجي وأزرار Play All و Shuffle وقائمة المسارات الكاملة
class PlaylistDetailsScreen extends StatelessWidget {
  final PlaylistModel playlist;

  const PlaylistDetailsScreen({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsCubit>().state.isArabic;

    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, playlistsState) {
        // العثور على النسخة المحدثة الحية من القائمة
        final currentPlaylist = playlistsState.playlists.firstWhere(
          (p) => p.id == playlist.id,
          orElse: () => playlist,
        );

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg(context),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textPrimaryColor(context),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              isAr ? 'قائمة التشغيل' : 'Playlist',
              style: AppStyles.font18Bold,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  size: 26,
                  color: AppColors.textPrimaryColor(context),
                ),
                onPressed: () => _showPlaylistMenu(context, currentPlaylist, isAr),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg(context),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(AppColors.isDark ? 50 : 10),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: const AppDeveloperFooter(
                showDivider: true,
                padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
              ),
            ),
          ),
          body: BlocBuilder<NowPlayingCubit, NowPlayingState>(
            builder: (context, playerState) {
              final bottomSpacing = playerState.isMiniPlayerVisible ? 85.0 : 16.0;

              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 12.0,
                      bottom: bottomSpacing,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // بطاقة الغلاف والترويسة الكبيرة (Hero Banner)
                        _buildHeroBanner(context, currentPlaylist, isAr),

                        const SizedBox(height: 20),

                        // صفا زري التشغيل والخلط (Play All & Shuffle Buttons)
                        _buildActionButtons(context, currentPlaylist, isAr),

                        const SizedBox(height: 28),

                        // عنوان قسم المقاطع الصوتية
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'المقاطع الصوتية' : 'Tracks',
                              style: AppStyles.font18Bold,
                            ),
                            Text(
                              '${currentPlaylist.tracks.length} ${isAr ? 'مقطع' : 'Songs'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // قائمة المسارات الصوتية
                        if (currentPlaylist.tracks.isEmpty)
                          _buildEmptyState(context, isAr)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentPlaylist.tracks.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final track = currentPlaylist.tracks[index];
                              final isCurrent = playerState.currentTrack?.id == track.id;
                              final isPlaying = isCurrent && playerState.status == PlaybackStatus.playing;

                              return _buildTrackTile(
                                context: context,
                                track: track,
                                isCurrent: isCurrent,
                                isPlaying: isPlaying,
                                playlist: currentPlaylist,
                                isAr: isAr,
                              );
                            },
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // المشغل المصغر العائم المستمر
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MiniPlayer(),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// بناء الغلاف والترويسة البارزة (Hero Banner)
  Widget _buildHeroBanner(BuildContext context, PlaylistModel currentPlaylist, bool isAr) {
    return Container(
      width: double.infinity,
      height: 195,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.getShadow(context),
        gradient: currentPlaylist.isGradient || currentPlaylist.coverUrl == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B1578),
                  Color(0xFF1E2875),
                  Color(0xFF1565C0),
                ],
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // صورة الغلاف إن توفرت
            if (!currentPlaylist.isGradient && currentPlaylist.coverUrl != null)
              Positioned.fill(
                child: Image.network(
                  currentPlaylist.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1E2538)),
                ),
              ),

            // تدرج لوني داكن خفيف للقراءة بوضوح
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(190),
                    ],
                  ),
                ),
              ),
            ),

            // نصوص العنوان وعدد المسارات والمدة الكلية
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentPlaylist.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${currentPlaylist.tracks.length} ${isAr ? 'أغنية' : 'Songs'} • ${_calculateTotalDuration(currentPlaylist.tracks, isAr)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(210),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// زرا الإجراءات الرئيسية: Play All و Shuffle
  Widget _buildActionButtons(BuildContext context, PlaylistModel currentPlaylist, bool isAr) {
    return Row(
      children: [
        // زر Play All الأزرق البارز
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (currentPlaylist.tracks.isNotEmpty) {
                context.read<NowPlayingCubit>().playOrToggleTrack(
                      currentPlaylist.tracks.first,
                      queue: currentPlaylist.tracks,
                    );
              }
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.glowingBlueShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'تشغيل الكل' : 'Play All',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // زر Shuffle العشوائي الأنيق
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (currentPlaylist.tracks.isNotEmpty) {
                final shuffled = List<TrackModel>.from(currentPlaylist.tracks)..shuffle();
                final nowPlayingCubit = context.read<NowPlayingCubit>();
                if (!nowPlayingCubit.state.isShuffleEnabled) {
                  nowPlayingCubit.toggleShuffle();
                }
                nowPlayingCubit.playOrToggleTrack(
                  shuffled.first,
                  queue: shuffled,
                );
              }
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.isDark ? const Color(0xFF18192E) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.isDark ? const Color(0xFF282A45) : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: AppColors.isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : AppColors.softShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shuffle_rounded,
                    color: AppColors.isDark ? Colors.white : AppColors.textPrimary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'خلط عشوائي' : 'Shuffle',
                    style: TextStyle(
                      color: AppColors.isDark ? Colors.white : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بطاقة المقطع الصوتي داخل القائمة
  Widget _buildTrackTile({
    required BuildContext context,
    required TrackModel track,
    required bool isCurrent,
    required bool isPlaying,
    required PlaylistModel playlist,
    required bool isAr,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<NowPlayingCubit>().playOrToggleTrack(
              track,
              queue: playlist.tracks,
            );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.getShadow(context),
        ),
        child: Row(
          children: [
            // صورة أو أيقونة المقطع الصوتي
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                AssetsKeys.musicNoteIcon,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 14),

            // عنوان المقطع واسم الفنان والمدة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: AppStyles.font16SemiBold.copyWith(
                      color: isCurrent ? AppColors.primaryBlue : AppColors.textPrimaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${track.artist} • ${_formatTrackDuration(track.duration)}',
                    style: AppStyles.font14Regular.copyWith(
                      color: AppColors.textSecondaryColor(context),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // أيقونة الحالة (تشغيل أو المزيد)
            if (isCurrent)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
              ),

            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondaryColor(context),
                size: 22,
              ),
              splashRadius: 20,
              onPressed: () => _showTrackOptions(context, track, playlist, isAr),
            ),
          ],
        ),
      ),
    );
  }

  /// الحالة الفارغة عند عدم وجود مقاطع
  Widget _buildEmptyState(BuildContext context, bool isAr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_off_rounded,
              size: 56,
              color: AppColors.textSecondaryColor(context).withAlpha(120),
            ),
            const SizedBox(height: 14),
            Text(
              isAr
                  ? 'لا توجد مقاطع صوتية في هذه القائمة بعد'
                  : 'No audio tracks in this playlist yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? 'يمكنك إضافة المقاطع من الشاشة الرئيسية عبر زر الخيارات (⋮)'
                  : 'Add songs from Home screen using the options button (⋮)',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// قائمة خيارات القائمة الكاملة (Playlist Menu)
  void _showPlaylistMenu(BuildContext context, PlaylistModel currentPlaylist, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // تشغيل الكل
                ListTile(
                  leading: const Icon(Icons.play_arrow_rounded, color: AppColors.primaryBlue),
                  title: Text(isAr ? 'تشغيل القائمة' : 'Play Playlist', style: AppStyles.font14SemiBold),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    if (currentPlaylist.tracks.isNotEmpty) {
                      context.read<NowPlayingCubit>().playOrToggleTrack(
                            currentPlaylist.tracks.first,
                            queue: currentPlaylist.tracks,
                          );
                    }
                  },
                ),

                // خلط عشوائي
                ListTile(
                  leading: const Icon(Icons.shuffle_rounded, color: AppColors.primaryBlue),
                  title: Text(isAr ? 'تشغيل عشوائي' : 'Shuffle Play', style: AppStyles.font14SemiBold),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    if (currentPlaylist.tracks.isNotEmpty) {
                      final shuffled = List<TrackModel>.from(currentPlaylist.tracks)..shuffle();
                      context.read<NowPlayingCubit>().playOrToggleTrack(
                            shuffled.first,
                            queue: shuffled,
                          );
                    }
                  },
                ),

                // تعديل اسم القائمة
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: AppColors.textPrimaryColor(context)),
                  title: Text(isAr ? 'تعديل اسم القائمة' : 'Rename Playlist', style: AppStyles.font14SemiBold),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _showRenamePlaylistDialog(context, currentPlaylist, isAr);
                  },
                ),

                // حذف القائمة
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: Text(
                    isAr ? 'حذف القائمة' : 'Delete Playlist',
                    style: AppStyles.font14SemiBold.copyWith(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _showDeletePlaylistDialog(context, currentPlaylist, isAr);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// خيارات المقطع الصوتي الفردي
  void _showTrackOptions(BuildContext context, TrackModel track, PlaylistModel currentPlaylist, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ترويسة المقطع
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(AssetsKeys.musicNoteIcon, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.title, style: AppStyles.font16SemiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${track.artist} • ${_formatTrackDuration(track.duration)}', style: AppStyles.font14Regular),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.divider(context), height: 1),
                const SizedBox(height: 8),

                // تشغيل التالي
                ListTile(
                  leading: Icon(Icons.playlist_play_rounded, color: AppColors.textPrimaryColor(context)),
                  title: Text(isAr ? 'تشغيل التالي' : 'Play Next', style: AppStyles.font14SemiBold),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    context.read<NowPlayingCubit>().playNext(track);
                  },
                ),

                // إضافة لقائمة الانتظار
                ListTile(
                  leading: Icon(Icons.queue_music_rounded, color: AppColors.textPrimaryColor(context)),
                  title: Text(isAr ? 'إضافة لقائمة الانتظار' : 'Add to Queue', style: AppStyles.font14SemiBold),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    context.read<NowPlayingCubit>().addToQueue(track);
                  },
                ),

                // حذف من هذه القائمة
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  title: Text(
                    isAr ? 'إزالة من هذه القائمة' : 'Remove from Playlist',
                    style: AppStyles.font14SemiBold.copyWith(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    context.read<PlaylistsCubit>().removeTrackFromPlaylist(currentPlaylist.id, track.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// حوار تعديل اسم القائمة
  void _showRenamePlaylistDialog(BuildContext context, PlaylistModel currentPlaylist, bool isAr) {
    final controller = TextEditingController(text: currentPlaylist.title);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(dialogCtx),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isAr ? 'تعديل اسم القائمة' : 'Rename Playlist', style: AppStyles.font18Bold),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: AppColors.textPrimaryColor(dialogCtx)),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.isDark ? const Color(0xFF1E2538) : AppColors.surfaceMuted,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(isAr ? 'إلغاء' : 'Cancel', style: TextStyle(color: AppColors.textSecondaryColor(dialogCtx))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final newTitle = controller.text.trim();
                if (newTitle.isNotEmpty) {
                  context.read<PlaylistsCubit>().renamePlaylist(currentPlaylist.id, newTitle);
                  Navigator.pop(dialogCtx);
                }
              },
              child: Text(isAr ? 'حفظ' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// حوار تأكيد حذف القائمة
  void _showDeletePlaylistDialog(BuildContext context, PlaylistModel currentPlaylist, bool isAr) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(dialogCtx),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(isAr ? 'تأكيد الحذف' : 'Confirm Delete', style: AppStyles.font18Bold),
            ],
          ),
          content: Text(
            isAr
                ? 'هل أنت متأكد من حذف قائمة "${currentPlaylist.title}"؟'
                : 'Are you sure you want to delete "${currentPlaylist.title}"?',
            style: AppStyles.font14Regular.copyWith(color: AppColors.textPrimaryColor(dialogCtx)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(isAr ? 'إلغاء' : 'Cancel', style: TextStyle(color: AppColors.textSecondaryColor(dialogCtx))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.read<PlaylistsCubit>().deletePlaylist(currentPlaylist.id);
                Navigator.pop(dialogCtx); // إغلاق الحوار
                Navigator.pop(context); // الرجوع إلى شاشة القوائم
              },
              child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// تنسيق مدة المقطع الفردي
  String _formatTrackDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// حساب وتنسيق المدة الإجمالية للقائمة
  String _calculateTotalDuration(List<TrackModel> tracks, bool isAr) {
    final totalSeconds = tracks.fold<int>(0, (sum, t) => sum + t.duration.inSeconds);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return isAr ? '$hours ساعة و $minutes دقيقة' : '${hours}h ${minutes}m';
    } else {
      return isAr ? '$minutes دقيقة' : '${minutes}m';
    }
  }
}

