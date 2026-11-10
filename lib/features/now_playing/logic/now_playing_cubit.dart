import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'now_playing_state.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../core/shared/models/track_model.dart';
import '../../../core/shared/enums/playback_state.dart';

/// كيبوت مشغل الموسيقى (Now Playing Cubit)
/// مسؤول عن استقبال أوامر المستخدم وتحديث حالة التشغيل عبر AudioPlayerService
class NowPlayingCubit extends Cubit<NowPlayingState> {
  final AudioPlayerService _audioPlayerService;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _volumeSub;
  StreamSubscription? _indexSub;

  NowPlayingCubit(this._audioPlayerService) : super(const NowPlayingState()) {
    _initAudioStreams();
  }

  /// الاستماع للتدفقات الصادرة من مشغل الصوت (Event Listeners)
  void _initAudioStreams() {
    // مراقبة الموضع الزمني الحالي وتحديث شريط التقدم
    _positionSub = _audioPlayerService.positionStream.listen((pos) {
      emit(state.copyWith(position: pos));
    });

    // مراقبة إجمالي مدة المقطع
    _durationSub = _audioPlayerService.durationStream.listen((dur) {
      if (dur != null) {
        emit(state.copyWith(duration: dur));
      }
    });

    // مراقبة تغير حالة المشغل (Play/Pause/Buffering/Completed)
    _playerStateSub = _audioPlayerService.playerStateStream.listen((playerState) {
      final status = _audioPlayerService.mapPlayerStateToStatus(playerState);
      emit(state.copyWith(
        status: status,
        repeatMode: _audioPlayerService.repeatMode,
        isShuffleEnabled: _audioPlayerService.isShuffleEnabled,
      ));

      // إذا انتهى المقطع الصوتي، الانتقال التلقائي للمقطع التالي
      if (status == PlaybackStatus.completed) {
        playNextTrack();
      }
    });

    // مراقبة تغير مستوى الصوت
    _volumeSub = _audioPlayerService.volumeStream.listen((vol) {
      emit(state.copyWith(volume: vol));
    });

    // مراقبة تغير المقطع الصوتي الحالي (عبر أزرار التالي/السابق في الإشعارات وشاشة القفل)
    _indexSub = _audioPlayerService.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < state.queue.length) {
        final current = state.queue[index];
        if (state.currentTrack?.id != current.id) {
          emit(state.copyWith(
            currentTrack: current,
            duration: current.duration,
            position: Duration.zero,
          ));
        }
      }
    });
  }

  /// تعيين قائمة انتظار التشغيل (Queue) والمقطع الحالي مع خيار التحكم بالتشغيل التلقائي
  void setQueue(List<TrackModel> tracks, {TrackModel? startTrack, bool autoPlay = true}) {
    emit(state.copyWith(
      queue: tracks,
      currentTrack: startTrack,
      duration: startTrack?.duration ?? Duration.zero,
      status: startTrack != null ? PlaybackStatus.paused : PlaybackStatus.initial,
      isMiniPlayerVisible: autoPlay && startTrack != null,
    ));
    if (autoPlay && startTrack != null) {
      playTrack(startTrack);
    } else if (startTrack != null) {
      _audioPlayerService.prepareTrack(startTrack);
    }
  }

  /// تشغيل المقطع أو تبديل حالته بين التشغيل والإيقاف إذا كان هو نفسه المقطع الحالي
  Future<void> playOrToggleTrack(TrackModel track, {List<TrackModel>? queue}) async {
    final effectiveQueue = (queue != null && queue.isNotEmpty) ? queue : state.queue;
    if (effectiveQueue.isNotEmpty) {
      emit(state.copyWith(queue: effectiveQueue));
    }

    // إذا كان المقطع هو نفسه المشغل حالياً والمشغل ظاهر بالفعل، نقوم بتبديل التشغيل/الإيقاف
    if (state.currentTrack?.id == track.id && state.isMiniPlayerVisible) {
      await togglePlayPause();
    } else {
      final index = effectiveQueue.indexWhere((t) => t.id == track.id);
      if (effectiveQueue.isNotEmpty && index != -1) {
        emit(state.copyWith(
          status: PlaybackStatus.loading,
          currentTrack: track,
          duration: track.duration,
          position: Duration.zero,
          isMiniPlayerVisible: true,
        ));
        try {
          await _audioPlayerService.setPlaylist(
            effectiveQueue,
            initialIndex: index,
            autoPlay: true,
          );
          emit(state.copyWith(status: PlaybackStatus.playing));
        } catch (e) {
          emit(state.copyWith(
            status: PlaybackStatus.error,
            errorMessage: 'تعذر تشغيل المقطع الصوتي: $e',
          ));
        }
      } else {
        await playTrack(track);
      }
    }
  }

  /// إضافة المقطع الصوتي للتشغيل التالي مباشرة بعد المقطع الحالي
  void playNext(TrackModel track) {
    final updatedQueue = List<TrackModel>.from(state.queue);
    if (state.currentTrack != null) {
      updatedQueue.removeWhere((t) => t.id == track.id);
      final currentIndex = updatedQueue.indexWhere((t) => t.id == state.currentTrack!.id);
      if (currentIndex != -1) {
        updatedQueue.insert(currentIndex + 1, track);
      } else {
        updatedQueue.add(track);
      }
    } else {
      updatedQueue.add(track);
    }
    emit(state.copyWith(queue: updatedQueue));
  }

  /// إضافة المقطع الصوتي إلى نهاية قائمة الانتظار الحالية
  void addToQueue(TrackModel track) {
    final updatedQueue = List<TrackModel>.from(state.queue);
    if (!updatedQueue.any((t) => t.id == track.id)) {
      updatedQueue.add(track);
      emit(state.copyWith(queue: updatedQueue));
    }
  }

  /// تبديل حالة التفضيل للمقطع الصوتي (Favorite Toggle)
  void toggleFavorite(TrackModel track) {
    final isFav = !track.isFavorite;
    final updatedTrack = track.copyWith(isFavorite: isFav);
    final updatedQueue = state.queue.map((t) => t.id == track.id ? updatedTrack : t).toList();
    final updatedCurrent = state.currentTrack?.id == track.id ? updatedTrack : state.currentTrack;
    emit(state.copyWith(
      queue: updatedQueue,
      currentTrack: updatedCurrent,
    ));
  }

  /// تحديث اسم المقطع الصوتي إذا كان موجوداً في قائمة التشغيل أو يعمل حالياً
  void updateTrackTitle(String trackId, String newTitle) {
    final updatedQueue = state.queue.map((t) {
      return t.id == trackId ? t.copyWith(title: newTitle.trim()) : t;
    }).toList();

    final updatedCurrent = state.currentTrack?.id == trackId
        ? state.currentTrack?.copyWith(title: newTitle.trim())
        : state.currentTrack;

    emit(state.copyWith(
      queue: updatedQueue,
      currentTrack: updatedCurrent,
    ));
  }

  /// إزالة المقطع الصوتي من قائمة التشغيل الحالية
  void removeTrackFromQueue(String trackId) {
    final updatedQueue = state.queue.where((t) => t.id != trackId).toList();
    TrackModel? nextCurrent = state.currentTrack;
    if (state.currentTrack?.id == trackId) {
      nextCurrent = updatedQueue.isNotEmpty ? updatedQueue.first : null;
      if (nextCurrent != null) {
        playTrack(nextCurrent);
      } else {
        _audioPlayerService.stop();
        emit(state.copyWith(
          status: PlaybackStatus.initial,
          currentTrack: null,
          queue: const [],
          isMiniPlayerVisible: false,
        ));
        return;
      }
    }
    emit(state.copyWith(
      queue: updatedQueue,
      currentTrack: nextCurrent,
    ));
  }

  /// إخفاء المشغل المصغر بعد سحبه من قبل المستخدم
  void dismissMiniPlayer() {
    emit(state.copyWith(isMiniPlayerVisible: false));
  }

  /// إظهار المشغل المصغر يدوياً
  void showMiniPlayer() {
    emit(state.copyWith(isMiniPlayerVisible: true));
  }

  /// بدء تشغيل مسار صوتي محدد
  Future<void> playTrack(TrackModel track) async {
    emit(state.copyWith(
      status: PlaybackStatus.loading,
      currentTrack: track,
      duration: track.duration,
      position: Duration.zero,
      isMiniPlayerVisible: true,
    ));

    try {
      await _audioPlayerService.playTrack(track);
      emit(state.copyWith(status: PlaybackStatus.playing));
    } catch (e) {
      emit(state.copyWith(
        status: PlaybackStatus.error,
        errorMessage: 'تعذر تشغيل المقطع الصوتي: $e',
      ));
    }
  }

  /// التبديل بين التشغيل والإيقاف المؤقت (Play/Pause Toggle)
  Future<void> togglePlayPause() async {
    if (state.status == PlaybackStatus.playing) {
      await _audioPlayerService.pause();
      emit(state.copyWith(status: PlaybackStatus.paused));
    } else {
      if (state.currentTrack != null) {
        await _audioPlayerService.resume();
        emit(state.copyWith(status: PlaybackStatus.playing, isMiniPlayerVisible: true));
      }
    }
  }

  /// الانتقال للمقطع التالي في القائمة
  Future<void> playNextTrack() async {
    if (state.queue.isEmpty || state.currentTrack == null) return;

    if (_audioPlayerService.hasNext) {
      await _audioPlayerService.seekToNext();
    } else {
      final currentIndex = state.queue.indexWhere((t) => t.id == state.currentTrack!.id);
      if (currentIndex != -1 && currentIndex + 1 < state.queue.length) {
        final nextTrack = state.queue[currentIndex + 1];
        await playTrack(nextTrack);
      } else if (state.queue.isNotEmpty) {
        // العودة لأول القائمة إذا وصلنا للنهاية
        await playTrack(state.queue.first);
      }
    }
  }

  /// الانتقال للمقطع السابق في القائمة
  Future<void> playPreviousTrack() async {
    if (state.queue.isEmpty || state.currentTrack == null) return;

    // إذا تجاوز التشغيل 3 ثوانٍ، نقوم بإعادة المقطع الحالي من البداية أولاً
    if (state.position.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }

    if (_audioPlayerService.hasPrevious) {
      await _audioPlayerService.seekToPrevious();
    } else {
      final currentIndex = state.queue.indexWhere((t) => t.id == state.currentTrack!.id);
      if (currentIndex > 0) {
        final prevTrack = state.queue[currentIndex - 1];
        await playTrack(prevTrack);
      } else if (state.queue.isNotEmpty) {
        await playTrack(state.queue.last);
      }
    }
  }

  /// القفز إلى موضع زمني داخل المقطع (Seek To Duration)
  Future<void> seekTo(Duration position) async {
    await _audioPlayerService.seek(position);
    emit(state.copyWith(position: position));
  }

  /// تعديل مستوى الصوت (0.0 إلى 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayerService.setVolume(volume);
    emit(state.copyWith(volume: volume));
  }

  /// تفعيل أو تعطيل وضع الخلط العشوائي (Shuffle)
  Future<void> toggleShuffle() async {
    await _audioPlayerService.toggleShuffle();
    emit(state.copyWith(isShuffleEnabled: _audioPlayerService.isShuffleEnabled));
  }

  /// التبديل بين خيارات التكرار (Repeat Mode)
  Future<void> toggleRepeatMode() async {
    await _audioPlayerService.toggleRepeatMode();
    emit(state.copyWith(repeatMode: _audioPlayerService.repeatMode));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _volumeSub?.cancel();
    _indexSub?.cancel();
    return super.close();
  }
}

