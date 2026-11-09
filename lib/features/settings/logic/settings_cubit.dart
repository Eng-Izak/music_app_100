import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_state.dart';
import '../../../core/shared/repos/preferences_repository.dart';
import '../../../core/theming/app_colors.dart';

/// كيبوت شاشة الإعدادات (Settings Cubit)
/// مسؤول عن حفظ واسترجاع تفضيلات المستخدم (الوضع الليلي، الإشعارات، تفعيل المعادل)
class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesRepository _preferencesRepository;

  SettingsCubit(this._preferencesRepository)
      : super(SettingsState(
          userProfile: _preferencesRepository.getUserProfile(),
          isDarkMode: _preferencesRepository.isDarkMode,
          isNotificationsEnabled: _preferencesRepository.isNotificationsEnabled,
          isEqualizerEnabled: _preferencesRepository.isEqualizerEnabled,
          languageCode: _preferencesRepository.language,
        )) {
    AppColors.isDark = _preferencesRepository.isDarkMode;
  }

  /// تبديل الوضع الداكن
  Future<void> toggleDarkMode(bool value) async {
    AppColors.isDark = value;
    await _preferencesRepository.setDarkMode(value);
    emit(state.copyWith(isDarkMode: value));
  }

  /// تبديل إشعارات التطبيق
  Future<void> toggleNotifications(bool value) async {
    await _preferencesRepository.setNotificationsEnabled(value);
    emit(state.copyWith(isNotificationsEnabled: value));
  }

  /// تفعيل أو تعطيل المعادل الصوتي
  Future<void> toggleEqualizer(bool value) async {
    await _preferencesRepository.setEqualizerEnabled(value);
    emit(state.copyWith(isEqualizerEnabled: value));
  }

  /// تفعيل أو تعطيل التلاشي المتبادل (Crossfade)
  void toggleCrossfade(bool value) {
    emit(state.copyWith(isCrossfadeEnabled: value));
  }

  /// تفعيل أو تعطيل التشغيل بلا فواصل (Gapless Playback)
  void toggleGapless(bool value) {
    emit(state.copyWith(isGaplessEnabled: value));
  }

  /// تغيير لغة عرض التطبيق ('ar' أو 'en')
  Future<void> setLanguage(String langCode) async {
    await _preferencesRepository.setLanguage(langCode);
    emit(state.copyWith(languageCode: langCode));
  }

  /// تحديث بيانات الملف الشخصي (الاسم والبريد الإلكتروني)
  Future<void> updateProfile({required String name, required String email}) async {
    final updated = state.userProfile.copyWith(name: name, email: email);
    await _preferencesRepository.saveUserProfile(updated);
    emit(state.copyWith(userProfile: updated));
  }

  /// تسجيل الخروج وإعادة تعيين الجلسة
  Future<void> logout() async {
    await _preferencesRepository.clearUserSession();
    final defaultProfile = _preferencesRepository.getUserProfile();
    emit(state.copyWith(userProfile: defaultProfile));
  }
}

