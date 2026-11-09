import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants/app_constants.dart';
import '../models/user_profile_model.dart';
import '../../utils/constants/assets_keys.dart';

/// مستودع تفضيلات المستخدم والإعدادات المحلية (Preferences Repository)
class PreferencesRepository {
  final SharedPreferences _prefs;

  PreferencesRepository(this._prefs);

  bool get isDarkMode => _prefs.getBool(AppConstants.prefDarkMode) ?? false;
  bool get isNotificationsEnabled => _prefs.getBool(AppConstants.prefNotifications) ?? true;
  bool get isEqualizerEnabled => _prefs.getBool(AppConstants.prefEqualizerEnabled) ?? true;
  String get language => _prefs.getString(AppConstants.prefLanguage) ?? 'en';

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(AppConstants.prefDarkMode, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(AppConstants.prefNotifications, value);
  }

  Future<void> setEqualizerEnabled(bool value) async {
    await _prefs.setBool(AppConstants.prefEqualizerEnabled, value);
  }

  Future<void> setLanguage(String langCode) async {
    await _prefs.setString(AppConstants.prefLanguage, langCode);
  }

  /// حفظ بيانات الملف الشخصي للمستخدم
  Future<void> saveUserProfile(UserProfileModel profile) async {
    await _prefs.setString(AppConstants.prefUserName, profile.name);
    await _prefs.setString(AppConstants.prefUserEmail, profile.email);
  }

  /// إعادة تعيين بيانات جلسة المستخدم عند تسجيل الخروج
  Future<void> clearUserSession() async {
    await _prefs.remove(AppConstants.prefUserName);
    await _prefs.remove(AppConstants.prefUserEmail);
  }

  /// جلب الملف الشخصي للمستخدم المعروض في شاشة الإعدادات
  UserProfileModel getUserProfile() {
    final name = _prefs.getString(AppConstants.prefUserName) ?? 'Alex Rivera';
    final email = _prefs.getString(AppConstants.prefUserEmail) ?? 'alex.music@icloud.com';
    return UserProfileModel(
      id: 'u1',
      name: name,
      email: email,
      avatarUrl: AssetsKeys.userAvatar,
    );
  }
}

