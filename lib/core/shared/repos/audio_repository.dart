import 'package:on_audio_query/on_audio_query.dart' hide PlaylistModel;
import 'package:permission_handler/permission_handler.dart';
import '../models/track_model.dart';
import '../models/playlist_model.dart';
import '../../utils/constants/assets_keys.dart';

/// مستودع المقاطع الصوتية وقوائم التشغيل (Audio Repository)
/// يقوم بطلب الإذن وقراءة جميع ملفات الصوت المخزنة في الجهاز وعرضها
class AudioRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// طلب صلاحيات الوصول إلى ملفات الصوت المخزنة في الجهاز
  Future<bool> requestPermissions() async {
    // التحقق من صلاحيات الصوت لنظام Android 13+ (READ_MEDIA_AUDIO)
    var audioStatus = await Permission.audio.status;
    if (!audioStatus.isGranted) {
      audioStatus = await Permission.audio.request();
    }

    // التحقق من صلاحيات التخزين لنظام Android 12 وما دون (READ_EXTERNAL_STORAGE)
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
    }

    if (audioStatus.isGranted || storageStatus.isGranted) {
      return true;
    }

    // فحص إضافي عبر مكتبة on_audio_query
    return await _audioQuery.checkAndRequest(retryRequest: true);
  }

  /// فحص وقراءة جميع ملفات الصوت الموجودة في ذاكرة الجهاز
  Future<List<TrackModel>> getDeviceTracks() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return const [];
    }

    try {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // تصفية الملفات التي تزيد مدتها عن 5 ثوانٍ لاستبعاد نغمات الإشعارات القصيرة جداً
      final validSongs = songs.where((s) => (s.duration ?? 0) > 5000).toList();

      if (validSongs.isEmpty) {
        return const [];
      }

      return validSongs.map((song) {
        return TrackModel(
          id: song.id.toString(),
          title: song.title.isNotEmpty ? song.title : 'مقطع بدون عنوان',
          artist: (song.artist != null && song.artist != '<unknown>')
              ? song.artist!
              : 'فنان غير معروف',
          album: song.album ?? '',
          artworkUrl: AssetsKeys.midnightCityCover,
          audioUrl: song.data, // مسار الملف الصوتي الفعلي في الجهاز
          duration: Duration(milliseconds: song.duration ?? 0),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  /// جلب كافة المسارات الموسيقية (الأولوية لملفات الجهاز المحلية)
  Future<List<TrackModel>> getAllTracks() async {
    return await getDeviceTracks();
  }

  /// المقاطع الافتراضية التجريبية
  List<TrackModel> getDefaultTracks() {
    return const [];
  }

  /// جلب المقاطع التي تم الاستماع لها مؤخراً (Recent Section)
  Future<List<TrackModel>> getRecentTracks() async {
    final all = await getAllTracks();
    return all.take(3).toList();
  }

  /// جلب كافة قوائم التشغيل (Your Collections)
  /// تبدأ فارغة تماماً عند التثبيت بدون بيانات تلقائية مسبقة
  Future<List<PlaylistModel>> getPlaylists() async {
    return [];
  }
}
