import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

/// مراقب حالات البلوك العام (App Bloc Observer)
/// يسجل انتقالات الحالات والأخطاء لتسهيل تصحيح الأخطاء ومراقبة دورة حياة التطبيق
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('🔄 [${bloc.runtimeType}] انتقال الحالة: ${change.currentState} -> ${change.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('❌ [${bloc.runtimeType}] حدث خطأ: $error');
    super.onError(bloc, error, stackTrace);
  }
}

