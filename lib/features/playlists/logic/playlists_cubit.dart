import 'package:flutter_bloc/flutter_bloc.dart';
import 'playlists_state.dart';
import '../../../core/shared/repos/audio_repository.dart';
import '../../../core/shared/models/playlist_model.dart';
import '../../../core/shared/models/track_model.dart';
import '../../../core/utils/constants/assets_keys.dart';

/// كيبوت قوائم التشغيل (Playlists Cubit)
/// مسؤول عن جلب وتصفية قوائم التشغيل وإنشاء قوائم جديدة
class PlaylistsCubit extends Cubit<PlaylistsState> {
  final AudioRepository _audioRepository;

  PlaylistsCubit(this._audioRepository) : super(const PlaylistsState()) {
    loadPlaylists();
  }

  /// تحميل جميع قوائم التشغيل
  Future<void> loadPlaylists() async {
    emit(state.copyWith(status: PlaylistsStatus.loading));
    try {
      final playlists = await _audioRepository.getPlaylists();
      emit(state.copyWith(
        status: PlaylistsStatus.success,
        playlists: playlists,
        filteredPlaylists: playlists,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlaylistsStatus.error,
        errorMessage: 'فشل في تحميل قوائم التشغيل: $e',
      ));
    }
  }

  /// تصفية قوائم التشغيل بحسب نص البحث المدخل
  void searchPlaylists(String query) {
    if (query.trim().isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        filteredPlaylists: state.playlists,
      ));
      return;
    }

    final filtered = state.playlists.where((playlist) {
      return playlist.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredPlaylists: filtered,
    ));
  }

  /// إضافة قائمة تشغيل مخصصة جديدة مع خيار تحديد الغلاف
  void createPlaylist(String title, {String? coverUrl, bool isGradient = false}) {
    if (title.trim().isEmpty) return;

    final newPlaylist = PlaylistModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      trackCount: 0,
      coverUrl: isGradient ? null : (coverUrl ?? AssetsKeys.recentlyAddedCover),
      isGradient: isGradient,
      isNew: true,
      tracks: const [],
    );

    final updated = List<PlaylistModel>.from(state.playlists)..add(newPlaylist);
    emit(state.copyWith(
      playlists: updated,
      filteredPlaylists: updated,
    ));
    _audioRepository.savePlaylists(updated);
  }

  /// تحديث بيانات قائمة التشغيل (الاسم والغلاف)
  void updatePlaylist({
    required String playlistId,
    required String newTitle,
    String? newCoverUrl,
    bool isGradient = false,
  }) {
    if (newTitle.trim().isEmpty) return;
    final updated = state.playlists.map((pl) {
      if (pl.id == playlistId) {
        return pl.copyWith(
          title: newTitle.trim(),
          coverUrl: isGradient ? null : newCoverUrl,
          isGradient: isGradient,
        );
      }
      return pl;
    }).toList();

    emit(state.copyWith(
      playlists: updated,
      filteredPlaylists: updated,
    ));
    _audioRepository.savePlaylists(updated);
  }

  /// إضافة مقطع صوتي إلى قائمة تشغيل محددة
  void addTrackToPlaylist(String playlistId, TrackModel track) {
    final updatedPlaylists = state.playlists.map((pl) {
      if (pl.id == playlistId) {
        if (!pl.tracks.any((t) => t.id == track.id)) {
          final updatedTracks = List<TrackModel>.from(pl.tracks)..add(track);
          return pl.copyWith(
            tracks: updatedTracks,
            trackCount: updatedTracks.length,
          );
        }
      }
      return pl;
    }).toList();

    emit(state.copyWith(
      playlists: updatedPlaylists,
      filteredPlaylists: updatedPlaylists,
    ));
    _audioRepository.savePlaylists(updatedPlaylists);
  }

  /// حذف مقطع صوتي من قائمة تشغيل محددة
  void removeTrackFromPlaylist(String playlistId, String trackId) {
    final updatedPlaylists = state.playlists.map((pl) {
      if (pl.id == playlistId) {
        final updatedTracks = pl.tracks.where((t) => t.id != trackId).toList();
        return pl.copyWith(
          tracks: updatedTracks,
          trackCount: updatedTracks.length,
        );
      }
      return pl;
    }).toList();

    emit(state.copyWith(
      playlists: updatedPlaylists,
      filteredPlaylists: updatedPlaylists,
    ));
    _audioRepository.savePlaylists(updatedPlaylists);
  }

  /// حذف قائمة تشغيل بالكامل
  void deletePlaylist(String playlistId) {
    final updated = state.playlists.where((pl) => pl.id != playlistId).toList();
    emit(state.copyWith(
      playlists: updated,
      filteredPlaylists: updated,
    ));
    _audioRepository.savePlaylists(updated);
  }

  /// إعادة تسمية قائمة تشغيل
  void renamePlaylist(String playlistId, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final updated = state.playlists.map((pl) {
      if (pl.id == playlistId) {
        return pl.copyWith(title: newTitle.trim());
      }
      return pl;
    }).toList();

    emit(state.copyWith(
      playlists: updated,
      filteredPlaylists: updated,
    ));
    _audioRepository.savePlaylists(updated);
  }
}

