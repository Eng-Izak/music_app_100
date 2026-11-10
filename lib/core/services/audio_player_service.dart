import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../shared/enums/playback_state.dart';
import '../shared/enums/repeat_mode.dart';
import '../shared/models/track_model.dart';

/// خدمة مشغل الصوت الأساسية المبنية على مكتبة just_audio و just_audio_background
/// توفر واجهة موحدة للتحكم بالتشغيل، التكرار، الخلط، إشعارات شريط المهام وقفل الشاشة
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
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  TrackModel? get currentTrack => _currentTrack;
  AppRepeatMode get repeatMode => _repeatMode;
  bool get isShuffleEnabled => _isShuffleEnabled;
  bool get isPlaying => _player.playing;
  double get volume => _player.volume;
  bool get hasNext => _player.hasNext;
  bool get hasPrevious => _player.hasPrevious;

  /// بناء مصدر صوتي مرفق ببيانات المقطع لخدمة إشعارات النظام وقفل الشاشة
  AudioSource _createAudioSource(TrackModel track) {
    final url = track.audioUrl;
    Uri? artUri;
    if (track.artworkUrl.isNotEmpty) {
      if (track.artworkUrl.startsWith('http://') ||
          track.artworkUrl.startsWith('https://') ||
          track.artworkUrl.startsWith('file://')) {
        artUri = Uri.parse(track.artworkUrl);
      }
    }

    final mediaItem = MediaItem(
      id: track.id,
      album: track.album.isNotEmpty ? track.album : 'Unknown Album',
      title: track.title,
      artist: track.artist.isNotEmpty ? track.artist : 'Unknown Artist',
      artUri: artUri,
      duration: track.duration,
    );

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return AudioSource.uri(Uri.parse(url), tag: mediaItem);
    } else if (url.startsWith('content://')) {
      return AudioSource.uri(Uri.parse(url), tag: mediaItem);
    } else {
      return AudioSource.file(url, tag: mediaItem);
    }
  }

  /// تعيين قائمة تشغيل كاملة (ConcatenatingAudioSource) لتمكين الانتقال التلقائي والتحكم من الإشعار
  Future<void> setPlaylist(
    List<TrackModel> tracks, {
    int initialIndex = 0,
    bool autoPlay = true,
  }) async {
    if (tracks.isEmpty) return;
    final clampedIndex = initialIndex.clamp(0, tracks.length - 1);
    _currentTrack = tracks[clampedIndex];

    final sources = tracks.map(_createAudioSource).toList();
    final playlist = ConcatenatingAudioSource(children: sources);

    try {
      await _player.setAudioSource(
        playlist,
        initialIndex: clampedIndex,
        initialPosition: Duration.zero,
      );
      if (autoPlay) {
        await _player.play();
      }
    } catch (e) {
      if (autoPlay) {
        _player.play();
      }
    }
  }

  /// تحميل وتجهيز المقطع الصوتي دون بدء التشغيل التلقائي
  Future<void> prepareTrack(TrackModel track) async {
    _currentTrack = track;
    try {
      final source = _createAudioSource(track);
      await _player.setAudioSource(source);
    } catch (_) {}
  }

  /// تهيئة المقطع الصوتي المنفرد وتشغيله مباشرة
  Future<void> playTrack(TrackModel track) async {
    _currentTrack = track;
    try {
      final source = _createAudioSource(track);
      await _player.setAudioSource(source);
      await _player.play();
    } catch (e) {
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

  /// الانتقال للمقطع التالي في القائمة
  Future<void> seekToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  /// الانتقال للمقطع السابق في القائمة
  Future<void> seekToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
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
    if (_isShuffleEnabled) {
      await _player.shuffle();
    }
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
