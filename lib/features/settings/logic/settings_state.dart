import 'package:equatable/equatable.dart';
import '../../../core/shared/models/user_profile_model.dart';

/// حالة شاشة الإعدادات (Settings State)
class SettingsState extends Equatable {
  final UserProfileModel userProfile;
  final bool isDarkMode;
  final bool isNotificationsEnabled;
  final bool isEqualizerEnabled;
  final bool isCrossfadeEnabled;
  final bool isGaplessEnabled;
  final String languageCode;

  const SettingsState({
    required this.userProfile,
    this.isDarkMode = false,
    this.isNotificationsEnabled = true,
    this.isEqualizerEnabled = true,
    this.isCrossfadeEnabled = true,
    this.isGaplessEnabled = true,
    this.languageCode = 'en',
  });

  bool get isArabic => languageCode == 'ar';

  SettingsState copyWith({
    UserProfileModel? userProfile,
    bool? isDarkMode,
    bool? isNotificationsEnabled,
    bool? isEqualizerEnabled,
    bool? isCrossfadeEnabled,
    bool? isGaplessEnabled,
    String? languageCode,
  }) {
    return SettingsState(
      userProfile: userProfile ?? this.userProfile,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      isEqualizerEnabled: isEqualizerEnabled ?? this.isEqualizerEnabled,
      isCrossfadeEnabled: isCrossfadeEnabled ?? this.isCrossfadeEnabled,
      isGaplessEnabled: isGaplessEnabled ?? this.isGaplessEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
        userProfile,
        isDarkMode,
        isNotificationsEnabled,
        isEqualizerEnabled,
        isCrossfadeEnabled,
        isGaplessEnabled,
        languageCode,
      ];
}

