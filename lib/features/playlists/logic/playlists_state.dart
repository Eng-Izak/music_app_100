import 'package:equatable/equatable.dart';
import '../../../core/shared/models/playlist_model.dart';

enum PlaylistsStatus { initial, loading, success, error }

/// حالة شاشة قوائم التشغيل (Playlists State)
class PlaylistsState extends Equatable {
  final PlaylistsStatus status;
  final List<PlaylistModel> playlists;
  final List<PlaylistModel> filteredPlaylists;
  final String searchQuery;
  final String? errorMessage;

  const PlaylistsState({
    this.status = PlaylistsStatus.initial,
    this.playlists = const [],
    this.filteredPlaylists = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  PlaylistsState copyWith({
    PlaylistsStatus? status,
    List<PlaylistModel>? playlists,
    List<PlaylistModel>? filteredPlaylists,
    String? searchQuery,
    String? errorMessage,
  }) {
    return PlaylistsState(
      status: status ?? this.status,
      playlists: playlists ?? this.playlists,
      filteredPlaylists: filteredPlaylists ?? this.filteredPlaylists,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        playlists,
        filteredPlaylists,
        searchQuery,
        errorMessage,
      ];
}

