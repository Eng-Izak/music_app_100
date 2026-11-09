import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_styles.dart';
import '../../../core/routing/routes.dart';
import '../../../core/shared/models/playlist_model.dart';
import '../../now_playing/logic/now_playing_cubit.dart';
import '../logic/playlists_cubit.dart';
import '../logic/playlists_state.dart';
import 'widgets/playlist_card.dart';
import 'widgets/create_playlist_dialog.dart';

/// شاشة قوائم التشغيل (PlayListsScreen #3)
/// تطابق الصورة #3 المرفقة متضمنة شريط البحث والشبكة الثنائية للمجموعات وزر الإضافة
class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      body: SafeArea(
        child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
          builder: (context, state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90), // مساحة المشغل المصغر
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // الترويسة العلوية: أيقونة الموسيقى + العنوان + زر الإضافة الدائري الأزرق
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.library_music_rounded, color: AppColors.primaryBlue, size: 28),
                            const SizedBox(width: 10),
                            Text('Playlists', style: AppStyles.font28Bold),
                          ],
                        ),
                        // زر الإضافة الدائري الأزرق البارز
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dialogCtx) => CreatePlaylistDialog(
                                onSave: (title, coverUrl, isGradient) {
                                  context.read<PlaylistsCubit>().createPlaylist(
                                        title,
                                        coverUrl: coverUrl,
                                        isGradient: isGradient,
                                      );
                                },
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 26),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // شريط البحث "Search your library"
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg(context),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.getShadow(context),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.textSecondaryColor(context), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                context.read<PlaylistsCubit>().searchPlaylists(val);
                              },
                              style: TextStyle(color: AppColors.textPrimaryColor(context)),
                              decoration: InputDecoration(
                                hintText: isAr ? 'البحث في مكتبتك...' : 'Search your library...',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondaryColor(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // عنوان قسم المجموعات "Your Collections" مع زر "See all"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isAr ? 'مجموعاتك' : 'Your Collections', style: AppStyles.font22Bold),
                        if (state.filteredPlaylists.isNotEmpty)
                          TextButton(
                            onPressed: () {},
                            child: Text(isAr ? 'عرض الكل' : 'See all', style: AppStyles.font14Blue),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // شبكة ثنائية الأعمدة لقوائم التشغيل أو واجهة فارغة
                    if (state.filteredPlaylists.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.queue_music_rounded,
                              size: 54,
                              color: AppColors.textSecondaryColor(context).withAlpha(120),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isAr ? 'لا توجد قوائم تشغيل حالياً' : 'No playlists yet',
                              style: AppStyles.font16SemiBold.copyWith(
                                color: AppColors.textPrimaryColor(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isAr
                                  ? 'اضغط على زر (+) في الأعلى لإنشاء قائمتك الأولى'
                                  : 'Tap (+) above to create your first playlist',
                              textAlign: TextAlign.center,
                              style: AppStyles.font14Regular.copyWith(
                                color: AppColors.textSecondaryColor(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: state.filteredPlaylists.length,
                        itemBuilder: (context, index) {
                          final playlist = state.filteredPlaylists[index];
                          return PlaylistCard(
                            playlist: playlist,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Routes.playlistDetails,
                                arguments: playlist,
                              );
                            },
                            onPlayTap: () {
                              if (playlist.tracks.isNotEmpty) {
                                context.read<NowPlayingCubit>().playOrToggleTrack(
                                      playlist.tracks.first,
                                      queue: playlist.tracks,
                                    );
                              }
                            },
                            onLongPress: () {
                              _showPlaylistOptionsBottomSheet(context, playlist, isAr);
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// القائمة المنبثقة السفلية لخيارات قائمة التشغيل عند النقر المطول
  void _showPlaylistOptionsBottomSheet(BuildContext context, PlaylistModel playlist, bool isAr) {
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

                // ترويسة معلومات القائمة
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: playlist.isGradient ? AppColors.favoritesGradient : null,
                        color: const Color(0xFF1E2538),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: playlist.isGradient
                            ? const Icon(Icons.favorite, color: Colors.white, size: 26)
                            : (playlist.coverUrl != null
                                ? Image.network(
                                    playlist.coverUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note, color: Colors.white),
                                  )
                                : const Icon(Icons.music_note, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.title,
                            style: AppStyles.font16SemiBold.copyWith(
                              color: AppColors.textPrimaryColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${playlist.trackCount} ${isAr ? 'مقطع صوتي' : 'tracks'}',
                            style: AppStyles.font14Regular.copyWith(
                              color: AppColors.textSecondaryColor(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(color: AppColors.divider(context), height: 1),
                const SizedBox(height: 8),

                // خيار التشغيل المباشر
                ListTile(
                  leading: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primaryBlue, size: 26),
                  title: Text(
                    isAr ? 'تشغيل القائمة' : 'Play Playlist',
                    style: AppStyles.font14SemiBold.copyWith(
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    if (playlist.tracks.isNotEmpty) {
                      context.read<NowPlayingCubit>().playOrToggleTrack(
                            playlist.tracks.first,
                            queue: playlist.tracks,
                          );
                    }
                  },
                ),

                // خيار التعديل (الاسم والغلاف)
                ListTile(
                  leading: Icon(Icons.edit_note_rounded, color: AppColors.textPrimaryColor(context), size: 26),
                  title: Text(
                    isAr ? 'تعديل القائمة (الاسم والغلاف)' : 'Edit Playlist (Name & Cover)',
                    style: AppStyles.font14SemiBold.copyWith(
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _showEditPlaylistDialog(context, playlist);
                  },
                ),

                // خيار الحذف
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 26),
                  title: Text(
                    isAr ? 'حذف القائمة' : 'Delete Playlist',
                    style: AppStyles.font14SemiBold.copyWith(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _showDeletePlaylistDialog(context, playlist, isAr);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// نافذة تعديل بيانات القائمة
  void _showEditPlaylistDialog(BuildContext context, PlaylistModel playlist) {
    showDialog(
      context: context,
      builder: (dialogCtx) => CreatePlaylistDialog(
        isEdit: true,
        initialTitle: playlist.title,
        initialCoverUrl: playlist.coverUrl,
        initialIsGradient: playlist.isGradient,
        onSave: (title, coverUrl, isGradient) {
          context.read<PlaylistsCubit>().updatePlaylist(
                playlistId: playlist.id,
                newTitle: title,
                newCoverUrl: coverUrl,
                isGradient: isGradient,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديث قائمة "$title" بنجاح'),
              backgroundColor: AppColors.cardBg(context),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  /// نافذة تأكيد حذف قائمة التشغيل
  void _showDeletePlaylistDialog(BuildContext context, PlaylistModel playlist, bool isAr) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(dialogCtx),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
              const SizedBox(width: 8),
              Text(isAr ? 'تأكيد الحذف' : 'Confirm Delete', style: AppStyles.font18Bold),
            ],
          ),
          content: Text(
            isAr
                ? 'هل أنت متأكد من رغبتك في حذف قائمة "${playlist.title}" نهائياً؟'
                : 'Are you sure you want to permanently delete "${playlist.title}"?',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.read<PlaylistsCubit>().deletePlaylist(playlist.id);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'تم حذف قائمة "${playlist.title}"' : 'Playlist "${playlist.title}" deleted'),
                    backgroundColor: AppColors.cardBg(context),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

