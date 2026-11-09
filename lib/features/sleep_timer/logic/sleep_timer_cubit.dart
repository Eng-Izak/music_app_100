import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sleep_timer_state.dart';
import '../../../core/services/timer_service.dart';

/// كيبوت مؤقت النوم (Sleep Timer Cubit)
/// مسؤول عن إدارة مؤقت العد التنازلي وتحديث الوقت المستهدف للتوقف
class SleepTimerCubit extends Cubit<SleepTimerState> {
  final TimerService _timerService;
  StreamSubscription? _timerSub;

  SleepTimerCubit(this._timerService) : super(const SleepTimerState()) {
    _initTargetTime();
    _listenToTimerService();
  }

  void _initTargetTime() {
    final formattedTime = _timerService.getFormattedStopTargetTime(state.selectedDuration);
    emit(state.copyWith(targetStopTime: formattedTime));
  }

  void _listenToTimerService() {
    _timerSub = _timerService.remainingDurationStream.listen((remaining) {
      if (remaining.inSeconds > 0) {
        emit(state.copyWith(
          status: SleepTimerStatus.running,
          remainingDuration: remaining,
        ));
      } else if (state.status == SleepTimerStatus.running) {
        emit(state.copyWith(
          status: SleepTimerStatus.completed,
          remainingDuration: Duration.zero,
        ));
      }
    });
  }

  /// تغيير الساعات والدقائق المختارة يدوياً
  void updateDuration({int? hours, int? minutes}) {
    final currentHours = hours ?? state.selectedDuration.inHours;
    final currentMinutes = minutes ?? (state.selectedDuration.inMinutes % 60);

    final newDuration = Duration(hours: currentHours, minutes: currentMinutes);
    final formattedTarget = _timerService.getFormattedStopTargetTime(newDuration);

    emit(state.copyWith(
      selectedDuration: newDuration,
      targetStopTime: formattedTarget,
    ));
  }

  /// اختيار فترة مسبقة (15 دقيقة، 30 دقيقة، 45 دقيقة، أو ساعة كاملة)
  void selectPresetDuration(Duration duration) {
    final formattedTarget = _timerService.getFormattedStopTargetTime(duration);
    emit(state.copyWith(
      selectedDuration: duration,
      targetStopTime: formattedTarget,
    ));
  }

  /// بدء تشغيل المؤقت
  void startTimer() {
    _timerService.startTimer(state.selectedDuration);
    emit(state.copyWith(
      status: SleepTimerStatus.running,
      remainingDuration: state.selectedDuration,
    ));
  }

  /// إيقاف وإلغاء المؤقت
  void cancelTimer() {
    _timerService.cancelTimer();
    final formattedTarget = _timerService.getFormattedStopTargetTime(state.selectedDuration);
    emit(state.copyWith(
      status: SleepTimerStatus.idle,
      remainingDuration: Duration.zero,
      targetStopTime: formattedTarget,
    ));
  }

  @override
  Future<void> close() {
    _timerSub?.cancel();
    return super.close();
  }
}

