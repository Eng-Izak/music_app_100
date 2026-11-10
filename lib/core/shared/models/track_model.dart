import 'package:equatable/equatable.dart';

/// نموذج بيانات المسار الصوتي (Track Model)
/// يحتوي على تفاصيل الأغنية، الغلاف، الرابط الصوتي، والمدة
class TrackModel extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String artworkUrl;
  final String audioUrl;
  final Duration duration;
  final bool isFavorite;

  const TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album = '',
    required this.artworkUrl,
    required this.audioUrl,
    required this.duration,
    this.isFavorite = false,
  });

  /// دالة نسخ الكائن لتعديل بعض الخصائص بأمان (Immutability Pattern)
  TrackModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artworkUrl,
    String? audioUrl,
    Duration? duration,
    bool? isFavorite,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'artworkUrl': artworkUrl,
      'audioUrl': audioUrl,
      'durationMs': duration.inMilliseconds,
      'isFavorite': isFavorite,
    };
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String? ?? '',
      artworkUrl: json['artworkUrl'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        artworkUrl,
        audioUrl,
        duration,
        isFavorite,
      ];
}

