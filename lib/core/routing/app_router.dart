import 'package:flutter/material.dart';
import 'routes.dart';
import '../../features/main_shell/main_shell_screen.dart';
import '../../features/now_playing/ui/now_playing_screen.dart';
import '../../features/playlists/ui/playlists_screen.dart';
import '../../features/playlists/ui/playlist_details_screen.dart';
import '../../features/equalizer/ui/equalizer_screen.dart';
import '../../features/sleep_timer/ui/sleep_timer_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../core/shared/models/playlist_model.dart';

/// موجه مسارات التطبيق المركزي (Central App Router)
class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initial:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());

      case Routes.nowPlaying:
        // حركة انتقال انسيابية من الأسفل إلى الأعلى لشاشة مشغل الموسيقى (Slide Up Transition)
        return PageRouteBuilder(
          pageBuilder: (_, _, _) => const NowPlayingScreen(),
          transitionsBuilder: (_, animation, _, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        );

      case Routes.playlists:
        return MaterialPageRoute(builder: (_) => const PlaylistsScreen());

      case Routes.playlistDetails:
        final playlist = settings.arguments as PlaylistModel;
        return MaterialPageRoute(
          builder: (_) => PlaylistDetailsScreen(playlist: playlist),
        );

      case Routes.equalizer:
        return MaterialPageRoute(builder: (_) => const EqualizerScreen());

      case Routes.sleepTimer:
        return MaterialPageRoute(builder: (_) => const SleepTimerScreen());

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('المسار غير معرف: ${settings.name}')),
          ),
        );
    }
  }
}

