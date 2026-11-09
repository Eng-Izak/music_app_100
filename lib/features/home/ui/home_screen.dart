import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_styles.dart';
import '../../../core/shared/enums/playback_state.dart';
import '../../now_playing/logic/now_playing_cubit.dart';
import '../../now_playing/logic/now_playing_state.dart';
import '../../settings/logic/settings_cubit.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';
import 'widgets/all_tracks_list.dart';

/// الشاشة الرئيسية لتطبيق BeatFlow (HomeScreen #1)
/// تطابق الصورة #2 بدقة متناهية متضمنة تحية الترحيب، وقسم Recent، وقائمة All Tracks
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsCubit>().state.isArabic;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg(context),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            if (homeState.status == HomeStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
            }

            return BlocBuilder<NowPlayingCubit, NowPlayingState>(
              builder: (context, playerState) {
                return RefreshIndicator(
                  color: AppColors.primaryBlue,
                  onRefresh: () async {
                    await context.read<HomeCubit>().loadHomeData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.only(
                      bottom: playerState.isMiniPlayerVisible ? 90 : 20,
                    ),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ترويسة الشاشة: تحية الترحيب وزر البحث الدائري
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isAr ? 'مرحباً بعودتك' : 'Welcome back', style: AppStyles.font28Bold),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cardBg(context),
                                boxShadow: AppColors.getShadow(context),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.search, color: AppColors.textPrimaryColor(context), size: 22),
                                onPressed: () {
                                  // إجراء فتح البحث
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // قسم جميع المقاطع الصوتية (All Tracks Section)
                      AllTracksList(
                        tracks: homeState.allTracks,
                        activeTrackId: playerState.currentTrack?.id,
                        isPlaying: playerState.status == PlaybackStatus.playing,
                        onTrackTap: (track) {
                          context.read<NowPlayingCubit>().playOrToggleTrack(
                                track,
                                queue: homeState.allTracks,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            );
          },
        ),
      ),
    );
  }
}

