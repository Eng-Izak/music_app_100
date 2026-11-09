import 'package:flutter/material.dart';
import '../../../../core/theming/app_styles.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/shared/models/track_model.dart';

/// قسم المشغلات الأخيرة (Recent Section Carousel)
/// يعرض المقاطع المستمع إليها مؤخراً في قائمة أفقية أنيقة
class RecentGrid extends StatelessWidget {
  final List<TrackModel> tracks;
  final ValueChanged<TrackModel> onTrackTap;

  const RecentGrid({
    super.key,
    required this.tracks,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم مع زر See all
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent', style: AppStyles.font22Bold),
              TextButton(
                onPressed: () {},
                child: Text('See all', style: AppStyles.font14Blue),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // قائمة البطاقات الأفقية القابلة للتمرير
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tracks.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return GestureDetector(
                onTap: () => onTrackTap(track),
                child: SizedBox(
                  width: 155,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صورة الغلاف المربعة مع زوايا دائرية وظلال خفيفة
                      Container(
                        width: 155,
                        height: 155,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.getShadow(context),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            track.artworkUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.isDark ? const Color(0xFF1E2538) : AppColors.surfaceMuted,
                              child: Icon(
                                Icons.album,
                                size: 48,
                                color: AppColors.textSecondaryColor(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // عنوان المقطع الصوتي
                      Text(
                        track.title,
                        style: AppStyles.font16SemiBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // اسم الفنان
                      Text(
                        track.artist,
                        style: AppStyles.font14Regular,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

