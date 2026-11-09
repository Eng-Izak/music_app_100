import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';
import '../../../core/shared/repos/audio_repository.dart';

/// كيبوت الشاشة الرئيسية (Home Cubit)
/// مسؤول عن جلب المسارات المستمع إليها حديثاً وقائمة كافة المقاطع الصوتية
class HomeCubit extends Cubit<HomeState> {
  final AudioRepository _audioRepository;

  HomeCubit(this._audioRepository) : super(const HomeState()) {
    loadHomeData();
  }

  /// تحميل بيانات الشاشة الرئيسية
  Future<void> loadHomeData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final recent = await _audioRepository.getRecentTracks();
      final all = await _audioRepository.getAllTracks();
      emit(state.copyWith(
        status: HomeStatus.success,
        recentTracks: recent,
        allTracks: all,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'فشل في تحميل المقاطع الصوتية: $e',
      ));
    }
  }

  /// تعديل اسم المقطع الصوتي وتحديث الواجهة
  void renameTrack(String trackId, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final trimmed = newTitle.trim();
    final updatedAll = state.allTracks.map((t) {
      return t.id == trackId ? t.copyWith(title: trimmed) : t;
    }).toList();

    final updatedRecent = state.recentTracks.map((t) {
      return t.id == trackId ? t.copyWith(title: trimmed) : t;
    }).toList();

    emit(state.copyWith(
      allTracks: updatedAll,
      recentTracks: updatedRecent,
    ));
  }

  /// حذف المقطع الصوتي من القائمة المعروضة
  void deleteTrack(String trackId) {
    final updatedAll = state.allTracks.where((t) => t.id != trackId).toList();
    final updatedRecent = state.recentTracks.where((t) => t.id != trackId).toList();

    emit(state.copyWith(
      allTracks: updatedAll,
      recentTracks: updatedRecent,
    ));
  }
}

