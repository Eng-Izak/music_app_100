/// ثوابت التطبيق العامة المستخدمة عبر مختلف الطبقات (Global App Constants)
class AppConstants {
  static const String appName = 'BeatFlow';
  static const String appVersion = '2.4.0 (Build 120)';

  // مفاتيح التخزين المحلي (Shared Preferences Keys)
  static const String prefDarkMode = 'pref_dark_mode';
  static const String prefNotifications = 'pref_notifications';
  static const String prefEqualizerEnabled = 'pref_equalizer_enabled';
  static const String prefLanguage = 'pref_language';
  static const String prefUserName = 'pref_user_name';
  static const String prefUserEmail = 'pref_user_email';
  static const String prefLastTrackId = 'pref_last_track_id';

  // معايير المعادل الصوتي الافتراضية
  static const double minGainDb = -12.0;
  static const double maxGainDb = 12.0;
  static const List<String> frequencyBands = [
    '60Hz',
    '230Hz',
    '910Hz',
    '4kHz',
    '14kHz',
  ];
}

