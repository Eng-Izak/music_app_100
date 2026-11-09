import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/audio_stream_client.dart';
import '../services/audio_player_service.dart';
import '../services/equalizer_service.dart';
import '../services/timer_service.dart';
import '../shared/repos/audio_repository.dart';
import '../shared/repos/preferences_repository.dart';
import '../../features/home/logic/home_cubit.dart';
import '../../features/now_playing/logic/now_playing_cubit.dart';
import '../../features/playlists/logic/playlists_cubit.dart';
import '../../features/equalizer/logic/equalizer_cubit.dart';
import '../../features/sleep_timer/logic/sleep_timer_cubit.dart';
import '../../features/settings/logic/settings_cubit.dart';

final getIt = GetIt.instance;

/// إعداد حقن التبعيات المركزي لتطبيق BeatFlow (Dependency Injection Container)
/// يقوم بتسجيل الخدمات والمستودعات والـ Cubits بنمط كائن مفرد (Singleton & Factory)
Future<void> setupInjection() async {
  // 1. التخزين المحلي الخارجي (External Dependencies)
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // 2. شبكة الاتصال والعميل الصوتي (Network Client)
  getIt.registerLazySingleton<AudioStreamClient>(() => AudioStreamClient());

  // 3. الخدمات الأساسية (Core Services)
  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());
  getIt.registerLazySingleton<EqualizerService>(() => EqualizerService());
  getIt.registerLazySingleton<TimerService>(() => TimerService(getIt<AudioPlayerService>()));

  // 4. المستودعات (Repositories)
  getIt.registerLazySingleton<AudioRepository>(() => AudioRepository());
  getIt.registerLazySingleton<PreferencesRepository>(() => PreferencesRepository(getIt<SharedPreferences>()));

  // 5. طبقة إدارة الحالة (Feature Cubits)
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<AudioRepository>()));
  getIt.registerLazySingleton<NowPlayingCubit>(() => NowPlayingCubit(getIt<AudioPlayerService>()));
  getIt.registerFactory<PlaylistsCubit>(() => PlaylistsCubit(getIt<AudioRepository>()));
  getIt.registerLazySingleton<EqualizerCubit>(() => EqualizerCubit(getIt<EqualizerService>()));
  getIt.registerFactory<SleepTimerCubit>(() => SleepTimerCubit(getIt<TimerService>()));
  getIt.registerLazySingleton<SettingsCubit>(() => SettingsCubit(getIt<PreferencesRepository>()));
}

