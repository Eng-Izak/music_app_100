import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_styles.dart';
import '../../../../core/shared/models/playlist_model.dart';

/// بطاقة قائمة التشغيل في شبكة المجموعات (Playlist Card)
/// تدعم التدرج اللوني للبطاقة المفضلة وشارة "NEW" للأحدث
class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onLongPress;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    this.onPlayTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الحاوية الصورية أو التدرجية للغلاف
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.getShadow(context),
                gradient: playlist.isGradient ? AppColors.favoritesGradient : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // الغلاف الصوري إن وجد
                    if (!playlist.isGradient && playlist.coverUrl != null)
                      Positioned.fill(
                        child: Image.network(
                          playlist.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.isDark ? const Color(0xFF1E2538) : AppColors.surfaceMuted,
                            child: Icon(
                              Icons.music_note,
                              size: 40,
                              color: AppColors.textSecondaryColor(context),
                            ),
                          ),
                        ),
                      ),

                    // أيقونة القلب في المنتصف لقائمة Favorites
                    if (playlist.isGradient)
                      const Center(
                        child: Icon(Icons.favorite, size: 48, color: Colors.white),
                      ),

                    // شارة "NEW" الزرقاء على اليسار
                    if (playlist.isNew && !playlist.isGradient)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                    // زر التشغيل الدائري في الركن السفلي للبطاقة
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: GestureDetector(
                        onTap: onPlayTap ?? onTap,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: playlist.isGradient
                                ? Colors.black.withAlpha(70)
                                : AppColors.primaryBlue,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // عنوان قائمة التشغيل
          Text(
            playlist.title,
            style: AppStyles.font16SemiBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // عدد المقاطع داخل القائمة
          Text(
            '${playlist.trackCount} tracks',
            style: AppStyles.font14Regular,
          ),
        ],
      ),
    );
  }
}

