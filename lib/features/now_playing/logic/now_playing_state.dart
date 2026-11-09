import 'package:equatable/equatable.dart';
import '../../../core/shared/enums/playback_state.dart';
import '../../../core/shared/enums/repeat_mode.dart';
import '../../../core/shared/models/track_model.dart';

/// حالة مشغل الموسيقى (Now Playing State)
/// فئة غير قابلة للتعديل تمثل كافة معطيات شاشة المشغل بالكامل
class NowPlayingState extends Equatable {
  final PlaybackStatus status;
  final TrackModel? currentTrack;
  final List<TrackModel> queue;
  final Duration position;
  final Duration duration;
  final double volume;
  final AppRepeatMode repeatMode;
  final bool isShuffleEnabled;
  final bool isMiniPlayerVisible;
  final String? errorMessage;

  const NowPlayingState({
    this.status = PlaybackStatus.initial,
    this.currentTrack,
    this.queue = const [],
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 0.8,
    this.repeatMode = AppRepeatMode.off,
    this.isShuffleEnabled = false,
    this.isMiniPlayerVisible = false,
    this.errorMessage,
  });

  NowPlayingState copyWith({
    PlaybackStatus? status,
    TrackModel? currentTrack,
    List<TrackModel>? queue,
    Duration? position,
    Duration? duration,
    double? volume,
    AppRepeatMode? repeatMode,
    bool? isShuffleEnabled,
    bool? isMiniPlayerVisible,
    String? errorMessage,
  }) {
    return NowPlayingState(
      status: status ?? this.status,
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isMiniPlayerVisible: isMiniPlayerVisible ?? this.isMiniPlayerVisible,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentTrack,
        queue,
        position,
        duration,
        volume,
        repeatMode,
        isShuffleEnabled,
        isMiniPlayerVisible,
        errorMessage,
      ];
}

