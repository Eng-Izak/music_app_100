import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app_bloc_observer.dart';
import 'app/music_app.dart';
import 'core/dependency_injection/injection_container.dart';
import 'core/routing/app_router.dart';
import 'core/shared/repos/audio_repository.dart';
import 'features/now_playing/logic/now_playing_cubit.dart';

/// نقطة الانطلاق الرئيسية لتطبيق BeatFlow
void main() async {
  // التأكد من تهيئة قنوات Flutter المدمجة قبل استدعاء الخدمات
  WidgetsFlutterBinding.ensureInitialized();

  // ضبط ألوان شريط الحالة العلوي بالنظام ليكون شفافاً ومتناسقاً مع التصميم
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // تهيئة حقن التبعيات المركزي (GetIt Injection Container)
  await setupInjection();

  // تفعيل مراقب أحداث البلوك لتتبع انتقالات الحالة
  Bloc.observer = AppBlocObserver();

  // تجهيز قائمة الانتظار الافتراضية بالمقاطع دون تعيين مسار مبدئي ودون تشغيل تلقائي
  final allTracks = await getIt<AudioRepository>().getAllTracks();
  if (allTracks.isNotEmpty) {
    getIt<NowPlayingCubit>().setQueue(allTracks, startTrack: null, autoPlay: false);
  }

  // تشغيل التطبيق الجذري مع تمرير موجه المسارات
  runApp(MusicApp(appRouter: AppRouter()));
}
