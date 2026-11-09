import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/dependency_injection/injection_container.dart';
import '../core/routing/app_router.dart';
import '../core/routing/routes.dart';
import '../core/theming/app_theme.dart';
import '../core/theming/app_colors.dart';
import '../features/home/logic/home_cubit.dart';
import '../features/now_playing/logic/now_playing_cubit.dart';
import '../features/playlists/logic/playlists_cubit.dart';
import '../features/equalizer/logic/equalizer_cubit.dart';
import '../features/sleep_timer/logic/sleep_timer_cubit.dart';
import '../features/settings/logic/settings_cubit.dart';
import '../features/settings/logic/settings_state.dart';

/// التطبيق الجذري (Root Music Application)
/// يوفر حقن الـ Cubits لجميع أجزاء الشجرة البرمجية وتطبيق السمة وموجه المسارات واللغة
class MusicApp extends StatelessWidget {
  final AppRouter appRouter;

  const MusicApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => getIt<SettingsCubit>()),
        BlocProvider<NowPlayingCubit>(create: (_) => getIt<NowPlayingCubit>()),
        BlocProvider<HomeCubit>(create: (_) => getIt<HomeCubit>()),
        BlocProvider<PlaylistsCubit>(create: (_) => getIt<PlaylistsCubit>()),
        BlocProvider<EqualizerCubit>(create: (_) => getIt<EqualizerCubit>()),
        BlocProvider<SleepTimerCubit>(create: (_) => getIt<SleepTimerCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.isDarkMode != current.isDarkMode ||
            previous.languageCode != current.languageCode,
        builder: (context, settingsState) {
          AppColors.isDark = settingsState.isDarkMode;

          return MaterialApp(
            key: ValueKey('app_${settingsState.isDarkMode}_${settingsState.languageCode}'),
            title: 'BeatFlow Music Player',
            debugShowCheckedModeBanner: false,
            locale: Locale(settingsState.languageCode),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: Routes.initial,
            onGenerateRoute: appRouter.generateRoute,
            builder: (context, child) {
              return Directionality(
                textDirection: settingsState.isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
