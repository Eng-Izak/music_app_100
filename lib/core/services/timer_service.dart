import 'dart:async';
import 'package:intl/intl.dart';
import 'audio_player_service.dart';

/// خدمة مؤقت النوم (Sleep Timer Service)
/// تتيح إيقاف الموسيقى تلقائياً بعد مدة محددة مع التلاشي التدريجي لمستوى الصوت (Audio Fade-Out)
class TimerService {
  final AudioPlayerService _audioPlayerService;

  Timer? _countdownTimer;
  Duration _remainingDuration = Duration.zero;
  bool _isRunning = false;

  final _timerController = StreamController<Duration>.broadcast();
  Stream<Duration> get remainingDurationStream => _timerController.stream;

  TimerService(this._audioPlayerService);

  Duration get remainingDuration => _remainingDuration;
  bool get isRunning => _isRunning;

  /// حساب الوقت الفعلي الذي ستتوقف فيه الموسيقى بصيغة مقروءة (مثال: 11:30 PM)
  String getFormattedStopTargetTime(Duration duration) {
    final targetTime = DateTime.now().add(duration);
    return DateFormat('h:mm a').format(targetTime);
  }

  /// بدء تشغيل المؤقت الزمني
  void startTimer(Duration duration) {
    cancelTimer();
    _remainingDuration = duration;
    _isRunning = true;
    _timerController.add(_remainingDuration);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingDuration.inSeconds > 0) {
        _remainingDuration = _remainingDuration - const Duration(seconds: 1);
        _timerController.add(_remainingDuration);

        // التلاشي الطبيعي للصوت في آخر 15 ثانية (Natural Fade-Out)
        if (_remainingDuration.inSeconds <= 15) {
          final factor = _remainingDuration.inSeconds / 15.0;
          _audioPlayerService.setVolume(factor * 1.0);
        }
      } else {
        // انتهاء المؤقت: إيقاف الموسيقى وإعادة تعيين المؤقت
        cancelTimer();
        _audioPlayerService.pause();
      }
    });
  }

  /// إلغاء المؤقت الجاري
  void cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _isRunning = false;
    _remainingDuration = Duration.zero;
    _timerController.add(Duration.zero);
  }

  void dispose() {
    cancelTimer();
    _timerController.close();
  }
}

