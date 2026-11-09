import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theming/app_styles.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/models/track_model.dart';
import '../../../../core/shared/widgets/app_bottom_sheet.dart';
import '../../../../core/utils/constants/assets_keys.dart';
import '../../../now_playing/logic/now_playing_cubit.dart';
import '../../../playlists/logic/playlists_cubit.dart';
import '../../../playlists/logic/playlists_state.dart';
import '../../../settings/logic/settings_cubit.dart';
import '../../logic/home_cubit.dart';

/// قائمة جميع المقاطع الصوتية (All Tracks Vertical List)
/// تعرض المقاطع في قائمة رأسية مع الأيقونة الموحدة وزر الخيارات (3 نقط عمودية)
class AllTracksList extends StatelessWidget {
  final List<TrackModel> tracks;
  final ValueChanged<TrackModel> onTrackTap;
  final String? activeTrackId;
  final bool isPlaying;

  const AllTracksList({
    super.key,
    required this.tracks,
    required this.onTrackTap,
    this.activeTrackId,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsCubit>().state.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(isAr ? 'كافة المقاطع' : 'All Tracks', style: AppStyles.font22Bold),
        ),

        const SizedBox(height: 12),

        // قائمة المسارات الرأسية أو حالة عدم وجود مقاطع
        if (tracks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.cardBg(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.music_off_rounded,
                    size: 48,
                    color: AppColors.textSecondaryColor(context).withAlpha(120),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isAr ? 'لم يتم العثور على مقاطع صوتية' : 'No audio tracks found',
                    style: AppStyles.font16SemiBold.copyWith(
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr
                        ? 'تأكد من وجود ملفات صوتية على هاتفك ومنح صلاحية الوصول للملفات'
                        : 'Make sure audio files exist on your device and storage permission is granted',
                    textAlign: TextAlign.center,
                    style: AppStyles.font14Regular.copyWith(
                      color: AppColors.textSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: tracks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final track = tracks[index];
            final isCurrent = activeTrackId == track.id;

            return GestureDetector(
              onTap: () => onTrackTap(track),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardBg(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.getShadow(context),
                ),
                child: Row(
                  children: [
                    // أيقونة النغمة الموحدة
                    Container(
                      width: 52,
                      height: 52,
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

                    // عنوان المقطع واسم الفنان
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
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            style: AppStyles.font14Regular.copyWith(
                              color: AppColors.textSecondaryColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // أيقونة الثلاث نقط العمودية لخيارات وإعدادات الأغنية
                    IconButton(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textSecondaryColor(context),
                        size: 22,
                      ),
                      splashRadius: 22,
                      onPressed: () => _showTrackOptions(context, track),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// إظهار ورقة خيارات وإعدادات الأغنية السفلية
  void _showTrackOptions(BuildContext context, TrackModel track) {
    AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ترويسة المقطع الصوتي
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    AssetsKeys.musicNoteIcon,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: AppStyles.font16SemiBold.copyWith(
                          color: AppColors.textPrimaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${track.artist} • ${_formatDuration(track.duration)}',
                        style: AppStyles.font14Regular.copyWith(
                          color: AppColors.textSecondaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: AppColors.divider(context), height: 1),
            const SizedBox(height: 8),

            // قائمة الإجراءات والخيارات
            _buildOptionTile(
              context: context,
              icon: Icons.playlist_play_rounded,
              title: 'تشغيل التالي (Play Next)',
              onTap: () {
                Navigator.pop(context);
                context.read<NowPlayingCubit>().playNext(track);
                _showSnackBar(context, 'تمت إضافة "${track.title}" للتشغيل التالي');
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.queue_music_rounded,
              title: 'إضافة لقائمة الانتظار (Add to Queue)',
              onTap: () {
                Navigator.pop(context);
                context.read<NowPlayingCubit>().addToQueue(track);
                _showSnackBar(context, 'تمت الإضافة إلى قائمة الانتظار');
              },
            ),
            _buildOptionTile(
              context: context,
              icon: track.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              iconColor: track.isFavorite ? Colors.redAccent : AppColors.textPrimaryColor(context),
              title: track.isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
              onTap: () {
                Navigator.pop(context);
                context.read<NowPlayingCubit>().toggleFavorite(track);
                _showSnackBar(
                  context,
                  track.isFavorite ? 'تمت الإزالة من المفضلة' : 'تمت الإضافة إلى المفضلة',
                );
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.playlist_add_rounded,
              title: 'إضافة إلى قائمة تشغيل (Add to Playlist)',
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, track);
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.info_outline_rounded,
              title: 'تفاصيل ومعلومات المقطع (Track Info)',
              onTap: () {
                Navigator.pop(context);
                _showTrackDetailsDialog(context, track);
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.edit_outlined,
              title: 'تعديل اسم الأغنية (Rename Track)',
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, track);
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Icons.delete_outline_rounded,
              iconColor: Colors.redAccent,
              title: 'حذف الأغنية (Delete Track)',
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(context, track);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// حوار اختيار قائمة التشغيل لإضافة المقطع إليها
  void _showAddToPlaylistDialog(BuildContext context, TrackModel track) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return BlocBuilder<PlaylistsCubit, PlaylistsState>(
          builder: (context, playlistsState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('إضافة إلى قائمة تشغيل', style: AppStyles.font18Bold),
              content: SizedBox(
                width: double.maxFinite,
                child: playlistsState.playlists.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'لا توجد قوائم تشغيل حالياً، يرجى إنشاء قائمة أولاً من تبويب القوائم.',
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
                            subtitle: Text('${playlist.trackCount} مقطع', style: AppStyles.font12Medium),
                            onTap: () {
                              context.read<PlaylistsCubit>().addTrackToPlaylist(playlist.id, track);
                              Navigator.pop(dialogCtx);
                              _showSnackBar(context, 'تمت إضافة المقطع إلى "${playlist.title}"');
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('إغلاق', style: TextStyle(color: AppColors.textSecondaryColor(dialogCtx))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// حوار عرض تفاصيل وبيانات الملف الصوتي
  void _showTrackDetailsDialog(BuildContext context, TrackModel track) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تفاصيل المقطع الصوتي', style: AppStyles.font18Bold),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('اسم الأغنية:', track.title),
                _buildDetailItem('اسم الفنان:', track.artist),
                if (track.album.isNotEmpty) _buildDetailItem('الألبوم:', track.album),
                _buildDetailItem('المدة الزمنية:', _formatDuration(track.duration)),
                if (track.audioUrl.isNotEmpty) _buildDetailItem('مسار الملف الصوتي:', track.audioUrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً', style: TextStyle(color: AppColors.primaryBlue)),
            ),
          ],
        );
      },
    );
  }

  /// حوار تعديل اسم المقطع الصوتي
  void _showRenameDialog(BuildContext context, TrackModel track) {
    final controller = TextEditingController(text: track.title);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل اسم الأغنية', style: AppStyles.font18Bold),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppStyles.font14SemiBold.copyWith(color: AppColors.textPrimaryColor(context)),
            decoration: InputDecoration(
              hintText: 'أدخل الاسم الجديد للأغنية',
              hintStyle: AppStyles.font14Regular.copyWith(color: AppColors.textSecondaryColor(context)),
              filled: true,
              fillColor: AppColors.scaffoldBg(context),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('إلغاء', style: TextStyle(color: AppColors.textSecondaryColor(context))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  context.read<HomeCubit>().renameTrack(track.id, newName);
                  context.read<NowPlayingCubit>().updateTrackTitle(track.id, newName);
                  Navigator.pop(dialogCtx);
                  _showSnackBar(context, 'تم تعديل اسم الأغنية إلى "$newName"');
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  /// حوار تأكيد حذف المقطع الصوتي
  void _showDeleteConfirmDialog(BuildContext context, TrackModel track) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
              const SizedBox(width: 8),
              Text('تأكيد الحذف', style: AppStyles.font18Bold),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف أغنية "${track.title}" من القائمة؟',
            style: AppStyles.font14Regular.copyWith(color: AppColors.textPrimaryColor(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('إلغاء', style: TextStyle(color: AppColors.textSecondaryColor(context))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.read<HomeCubit>().deleteTrack(track.id);
                context.read<NowPlayingCubit>().removeTrackFromQueue(track.id);
                Navigator.pop(dialogCtx);
                _showSnackBar(context, 'تم حذف أغنية "${track.title}" من القائمة');
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  /// تنسيق المدة الزمنية بصيغة MM:SS
  static String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// عرض رسالة إشعار سريعة للمستخدم
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// عنصر عرض بند التفاصيل في حوار المعلومات
  static Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.font12Medium.copyWith(
              color: AppColors.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppStyles.font14SemiBold, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  /// عنصر خيار في ورقة الإعدادات
  static Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveColor = iconColor ?? AppColors.textPrimaryColor(context);
    final effectiveTextColor = textColor ?? effectiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: effectiveColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppStyles.font14SemiBold.copyWith(
                  color: effectiveTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
