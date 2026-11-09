import 'package:equatable/equatable.dart';

enum SleepTimerStatus { idle, running, completed }

/// حالة مؤقت النوم (Sleep Timer State)
class SleepTimerState extends Equatable {
  final SleepTimerStatus status;
  final Duration selectedDuration; // المدة المختارة (مثلاً 1 ساعة و 30 دقيقة)
  final Duration remainingDuration; // المدة المتبقية التنازلية
  final String targetStopTime; // وقت التوقف المستهدف (مثل 11:30 PM)

  const SleepTimerState({
    this.status = SleepTimerStatus.idle,
    this.selectedDuration = const Duration(hours: 1, minutes: 30),
    this.remainingDuration = Duration.zero,
    this.targetStopTime = '',
  });

  SleepTimerState copyWith({
    SleepTimerStatus? status,
    Duration? selectedDuration,
    Duration? remainingDuration,
    String? targetStopTime,
  }) {
    return SleepTimerState(
      status: status ?? this.status,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      targetStopTime: targetStopTime ?? this.targetStopTime,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedDuration,
        remainingDuration,
        targetStopTime,
      ];
}

