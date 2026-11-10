import 'package:equatable/equatable.dart';
import 'track_model.dart';

/// نموذج بيانات قائمة التشغيل (Playlist Model)
/// يدعم المجموعات مثل Favorites، Recently Added، Workout Mix وغيرها
class PlaylistModel extends Equatable {
  final String id;
  final String title;
  final int trackCount;
  final String? coverUrl;
  final bool isGradient;
  final bool isNew;
  final List<TrackModel> tracks;

  const PlaylistModel({
    required this.id,
    required this.title,
    required this.trackCount,
    this.coverUrl,
    this.isGradient = false,
    this.isNew = false,
    this.tracks = const [],
  });

  PlaylistModel copyWith({
    String? id,
    String? title,
    int? trackCount,
    String? coverUrl,
    bool? isGradient,
    bool? isNew,
    List<TrackModel>? tracks,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      title: title ?? this.title,
      trackCount: trackCount ?? this.trackCount,
      coverUrl: coverUrl ?? this.coverUrl,
      isGradient: isGradient ?? this.isGradient,
      isNew: isNew ?? this.isNew,
      tracks: tracks ?? this.tracks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'trackCount': trackCount,
      'coverUrl': coverUrl,
      'isGradient': isGradient,
      'isNew': isNew,
      'tracks': tracks.map((t) => t.toJson()).toList(),
    };
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final tracksList = (json['tracks'] as List<dynamic>?)
            ?.map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];
    return PlaylistModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      trackCount: json['trackCount'] as int? ?? tracksList.length,
      coverUrl: json['coverUrl'] as String?,
      isGradient: json['isGradient'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      tracks: tracksList,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        trackCount,
        coverUrl,
        isGradient,
        isNew,
        tracks,
      ];
}

