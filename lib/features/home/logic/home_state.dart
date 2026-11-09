import 'package:equatable/equatable.dart';
import '../../../core/shared/models/track_model.dart';

enum HomeStatus { initial, loading, success, error }

/// حالة الشاشة الرئيسية (Home State)
class HomeState extends Equatable {
  final HomeStatus status;
  final List<TrackModel> recentTracks;
  final List<TrackModel> allTracks;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.recentTracks = const [],
    this.allTracks = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<TrackModel>? recentTracks,
    List<TrackModel>? allTracks,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      recentTracks: recentTracks ?? this.recentTracks,
      allTracks: allTracks ?? this.allTracks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, recentTracks, allTracks, errorMessage];
}

