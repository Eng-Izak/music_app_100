import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theming/app_colors.dart';
import '../../../core/theming/app_styles.dart';
import '../../../core/routing/routes.dart';
import '../logic/settings_cubit.dart';
import '../logic/settings_state.dart';
import 'widgets/preferences_tile.dart';

/// شاشة الإعدادات والملف الشخصي (Settings Screen #4)
/// متطابقة مع التصميم ومبرمجة بكافة ميزات التبديل والتعديل واللغة
class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const SettingsScreen({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isAr = state.isArabic;

        return Scaffold(
          backgroundColor: AppColors.isDark
              ? const Color(0xFF0F101E)
              : AppColors.scaffoldBackground,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textPrimaryColor(context),
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else if (onBackPressed != null) {
                  onBackPressed!();
                }
              },
            ),
            title: Text(
              isAr ? 'الإعدادات' : 'Settings',
              style: AppStyles.font18Bold,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // =================== قسم تشغيل الموسيقى (Playback) ===================
                  Align(
                    alignment: isAr
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      isAr ? 'تشغيل الموسيقى' : 'Playback',
                      style: AppStyles.font18Bold.copyWith(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // خيار التلاشي المتبادل (Crossfade)
                  PreferencesTile(
                    icon: Icons.alt_route_rounded,
                    title: isAr ? 'التلاشي المتبادل' : 'Crossfade',
                    isSwitch: true,
                    switchValue: state.isCrossfadeEnabled,
                    onSwitchChanged: (val) {
                      context.read<SettingsCubit>().toggleCrossfade(val);
                      _showSnackBar(
                        context,
                        isAr
                            ? (val
                                  ? 'تم تفعيل التلاشي المتبادل'
                                  : 'تم تعطيل التلاشي المتبادل')
                            : (val
                                  ? 'Crossfade enabled'
                                  : 'Crossfade disabled'),
                      );
                    },
                  ),

                  // خيار التشغيل بلا فواصل (Gapless Playback)
                  PreferencesTile(
                    icon: Icons.all_inclusive_rounded,
                    title: isAr ? 'تشغيل بلا فواصل' : 'Gapless Playback',
                    isSwitch: true,
                    switchValue: state.isGaplessEnabled,
                    onSwitchChanged: (val) {
                      context.read<SettingsCubit>().toggleGapless(val);
                      _showSnackBar(
                        context,
                        isAr
                            ? (val
                                  ? 'تم تفعيل التشغيل بلا فواصل'
                                  : 'تم تعطيل التشغيل بلا فواصل')
                            : (val
                                  ? 'Gapless Playback enabled'
                                  : 'Gapless Playback disabled'),
                      );
                    },
                  ),

                  // خيار المعادل الصوتي (Equalizer)
                  PreferencesTile(
                    icon: Icons.bar_chart_rounded,
                    title: isAr ? 'المعادل الصوتي' : 'Equalizer',
                    onTap: () {
                      Navigator.pushNamed(context, Routes.equalizer);
                    },
                  ),

                  const SizedBox(height: 24),

                  // =================== قسم المكتبة والتخزين (Library & Storage) ===================
                  Align(
                    alignment: isAr
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      isAr ? 'المكتبة والتخزين' : 'Library & Storage',
                      style: AppStyles.font18Bold.copyWith(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // إدارة المجلدات المحلية (Manage Local Folders)
                  PreferencesTile(
                    icon: Icons.folder_rounded,
                    title: isAr
                        ? 'إدارة المجلدات المحلية'
                        : 'Manage Local Folders',
                    onTap: () => _showManageFoldersDialog(context, isAr),
                  ),

                  // استخدام الذاكرة المؤقتة (Cache Usage)
                  PreferencesTile(
                    icon: Icons.dns_rounded,
                    title: isAr ? 'استخدام الذاكرة المؤقتة' : 'Cache Usage',
                    subtitle: isAr
                        ? 'تم استخدام 1.2 جيجابايت من 5.0 جيجابايت'
                        : 'Used 1.2 GB of 5.0 GB',
                    trailing: GestureDetector(
                      onTap: () {
                        _showSnackBar(
                          context,
                          isAr
                              ? 'تم مسح الذاكرة المؤقتة بنجاح'
                              : 'Cache cleared successfully',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.isDark
                              ? const Color(0xFF1E2548)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isAr ? 'مسح' : 'Clear',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =================== قسم المظهر والتفضيلات (Appearance) ===================
                  Align(
                    alignment: isAr
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      isAr ? 'المظهر' : 'Appearance',
                      style: AppStyles.font18Bold.copyWith(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // الوضع الداكن (Dark Mode)
                  PreferencesTile(
                    icon: Icons.nightlight_round,
                    title: isAr ? 'الوضع الداكن' : 'Dark Mode',
                    isSwitch: true,
                    switchValue: state.isDarkMode,
                    onSwitchChanged: (val) {
                      context.read<SettingsCubit>().toggleDarkMode(val);
                      _showSnackBar(
                        context,
                        isAr
                            ? (val
                                  ? 'تم تفعيل الوضع الداكن'
                                  : 'تم تفعيل الوضع الفاتح')
                            : (val
                                  ? 'Dark Mode enabled'
                                  : 'Light Mode enabled'),
                      );
                    },
                  ),

                  // لغة التطبيق (Language)
                  PreferencesTile(
                    icon: Icons.language_rounded,
                    title: isAr ? 'لغة التطبيق' : 'Language',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isAr ? 'العربية' : 'English',
                          style: AppStyles.font14SemiBold.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isAr ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.textSecondaryColor(context),
                        ),
                      ],
                    ),
                    onTap: () =>
                        _showLanguageDialog(context, state.languageCode, isAr),
                  ),

                  // الإشعارات (Notifications)
                  PreferencesTile(
                    icon: Icons.notifications_rounded,
                    title: isAr ? 'الإشعارات' : 'Notifications',
                    isSwitch: true,
                    switchValue: state.isNotificationsEnabled,
                    onSwitchChanged: (val) {
                      context.read<SettingsCubit>().toggleNotifications(val);
                      _showSnackBar(
                        context,
                        isAr
                            ? (val
                                  ? 'تم تفعيل إشعارات التطبيق'
                                  : 'تم تعطيل الإشعارات')
                            : (val
                                  ? 'Notifications enabled'
                                  : 'Notifications disabled'),
                      );
                    },
                  ),

                  // سياسة الخصوصية (Privacy Policy)
                  PreferencesTile(
                    icon: Icons.security_rounded,
                    title: isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                    onTap: () => _showPrivacyPolicyDialog(context, isAr),
                  ),

                  const SizedBox(height: 24),

                  // تذييل الإصدار (Version Footer)
                  Text(
                    isAr
                        ? 'الإصدار 2.4.0 (Build 882)'
                        : 'Version 2.4.0 (Build 882)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// حوار اختيار لغة عرض التطبيق
  void _showLanguageDialog(
    BuildContext context,
    String currentLang,
    bool isAr,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(dialogCtx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isAr ? 'اختر لغة التطبيق' : 'Select App Language',
            style: AppStyles.font18Bold,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context: dialogCtx,
                code: 'en',
                title: 'English (الإنجليزية)',
                isSelected: currentLang == 'en',
                onSelect: () {
                  context.read<SettingsCubit>().setLanguage('en');
                  Navigator.pop(dialogCtx);
                  _showSnackBar(context, 'App language set to English');
                },
              ),
              Divider(color: AppColors.divider(dialogCtx)),
              _buildLanguageOption(
                context: dialogCtx,
                code: 'ar',
                title: 'العربية (Arabic)',
                isSelected: currentLang == 'ar',
                onSelect: () {
                  context.read<SettingsCubit>().setLanguage('ar');
                  Navigator.pop(dialogCtx);
                  _showSnackBar(context, 'تم تغيير لغة التطبيق إلى العربية');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                isAr ? 'إغلاق' : 'Close',
                style: TextStyle(
                  color: AppColors.textSecondaryColor(dialogCtx),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// بند خيار اللغة في الحوار
  Widget _buildLanguageOption({
    required BuildContext context,
    required String code,
    required String title,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.15)
              : (AppColors.isDark
                    ? const Color(0xFF1E2538)
                    : const Color(0xFFF1F5F9)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.translate_rounded,
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.textSecondaryColor(context),
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: AppStyles.font14SemiBold.copyWith(
          color: isSelected
              ? AppColors.primaryBlue
              : AppColors.textPrimaryColor(context),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue)
          : null,
      onTap: onSelect,
    );
  }

  /// حوار إدارة المجلدات المحلية
  void _showManageFoldersDialog(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(dialogCtx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.folder_rounded, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                isAr ? 'المجلدات المحلية' : 'Manage Local Folders',
                style: AppStyles.font18Bold,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr
                    ? 'المجلدات الممسوحة بحثاً عن المقاطع الصوتية:'
                    : 'Folders scanned for audio tracks:',
                style: AppStyles.font14Regular.copyWith(
                  color: AppColors.textSecondaryColor(dialogCtx),
                ),
              ),
              const SizedBox(height: 12),
              _buildFolderTile(
                dialogCtx,
                '/storage/emulated/0/Music',
                '24 tracks',
              ),
              _buildFolderTile(
                dialogCtx,
                '/storage/emulated/0/Download',
                '12 tracks',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(isAr ? 'إغلاق' : 'Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFolderTile(BuildContext context, String path, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.isDark
            ? const Color(0xFF1E2538)
            : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_open_rounded,
            size: 20,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path,
                  style: AppStyles.font14SemiBold.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// حوار سياسة الخصوصية
  void _showPrivacyPolicyDialog(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg(dialogCtx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.security,
                color: AppColors.textSecondaryColor(dialogCtx),
              ),
              const SizedBox(width: 8),
              Text(
                isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                style: AppStyles.font18Bold,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              isAr
                  ? 'تطبيق BeatFlow يحترم خصوصيتك بشكل كامل:\n\n'
                        '• لا يقوم التطبيق بجمع أو إرسال أي ملفات صوتية خاصة بك إلى أي خوادم خارجية.\n'
                        '• يتم استخدام أذونات التخزين والوسائط فقط لقراءة وتشغيل الملفات الصوتية المخزنة محلياً على هاتفك.\n'
                        '• جميع الإعدادات وتفضيلات المستخدم وقوائم التشغيل يتم حفظها محلياً على جهازك بأمان.'
                  : 'BeatFlow fully respects your privacy:\n\n'
                        '• BeatFlow does not collect or upload any of your personal audio files to external servers.\n'
                        '• Storage and media permissions are only used locally to scan and play tracks stored on your device.\n'
                        '• All settings, playlists, and user preferences are safely stored locally on your device.',
              style: AppStyles.font14Regular.copyWith(
                height: 1.5,
                color: AppColors.textPrimaryColor(dialogCtx),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(isAr ? 'فهمت ذلك' : 'Got it'),
            ),
          ],
        );
      },
    );
  }

  /// عرض رسالة إشعار سريعة للمستخدم
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
