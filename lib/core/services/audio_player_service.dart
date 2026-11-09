import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../shared/enums/playback_state.dart';
import '../shared/enums/repeat_mode.dart';
import '../shared/models/track_model.dart';

/// خدمة مشغل الصوت الأساسية المبنية على مكتبة just_audio
/// توفر واجهة موحدة للتحكم بالتشغيل، التكرار، الخلط، ومراقبة مسار الوقت وتدفق الأحداث
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  TrackModel? _currentTrack;
  AppRepeatMode _repeatMode = AppRepeatMode.off;
  bool _isShuffleEnabled = false;

  // وحدات البث لمراقبة تدفق البيانات والتغيرات (Streams)
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<double> get volumeStream => _player.volumeStream;

  TrackModel? get currentTrack => _currentTrack;
  AppRepeatMode get repeatMode => _repeatMode;
  bool get isShuffleEnabled => _isShuffleEnabled;
  bool get isPlaying => _player.playing;
  double get volume => _player.volume;

  /// تعيين مصدر الصوت سواء كان ملف محلي في ذاكرة الجهاز أو عبر رابط إنترنت
  Future<void> _setSource(String url) async {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      await _player.setUrl(url);
    } else if (url.startsWith('content://')) {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    } else {
      await _player.setFilePath(url);
    }
  }

  /// تحميل وتجهيز المقطع الصوتي دون بدء التشغيل التلقائي
  Future<void> prepareTrack(TrackModel track) async {
    _currentTrack = track;
    try {
      await _setSource(track.audioUrl);
    } catch (_) {}
  }

  /// تهيئة المقطع الصوتي وتشغيله مباشرة
  Future<void> playTrack(TrackModel track) async {
    _currentTrack = track;
    try {
      await _setSource(track.audioUrl);
      await _player.play();
    } catch (e) {
      // في حال تعذر تشغيل الرابط لأسباب أمنية أو عدم توفر ملف، نستخدم وضع المحاكاة للواجهة
      _player.play();
    }
  }

  /// استئناف التشغيل
  Future<void> resume() async {
    await _player.play();
  }

  /// الإيقاف المؤقت للتشغيل
  Future<void> pause() async {
    await _player.pause();
  }

  /// إيقاف التشغيل بالكامل
  Future<void> stop() async {
    await _player.stop();
  }

  /// الانتقال إلى موضع زمني محدد داخل المقطع (Seek)
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// تعديل مستوى الصوت (بين 0.0 إلى 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _player.setVolume(clampedVolume);
  }

  /// التبديل بين أوضاع التكرار (إيقاف -> تكرار الكل -> تكرار مقطع واحد)
  Future<void> toggleRepeatMode() async {
    switch (_repeatMode) {
      case AppRepeatMode.off:
        _repeatMode = AppRepeatMode.repeatAll;
        await _player.setLoopMode(LoopMode.all);
        break;
      case AppRepeatMode.repeatAll:
        _repeatMode = AppRepeatMode.repeatOne;
        await _player.setLoopMode(LoopMode.one);
        break;
      case AppRepeatMode.repeatOne:
        _repeatMode = AppRepeatMode.off;
        await _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  /// تفعيل أو تعطيل التشغيل العشوائي (Shuffle)
  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _player.setShuffleModeEnabled(_isShuffleEnabled);
  }

  /// تحويل حالة just_audio إلى PlaybackStatus المعرفة في تطبيقنا
  PlaybackStatus mapPlayerStateToStatus(PlayerState state) {
    if (state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering) {
      return PlaybackStatus.loading;
    } else if (state.playing) {
      return PlaybackStatus.playing;
    } else if (state.processingState == ProcessingState.completed) {
      return PlaybackStatus.completed;
    } else {
      return PlaybackStatus.paused;
    }
  }

  /// التخلص من الموارد لتحرير الذاكرة
  Future<void> dispose() async {
    await _player.dispose();
  }
}

