import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theming/app_colors.dart';
import '../../core/shared/widgets/mini_player.dart';
import '../../core/shared/widgets/app_developer_footer.dart';
import '../settings/logic/settings_cubit.dart';
import '../settings/logic/settings_state.dart';
import '../home/ui/home_screen.dart';
import '../playlists/ui/playlists_screen.dart';
import '../sleep_timer/ui/sleep_timer_screen.dart';
import '../settings/ui/settings_screen.dart';

/// الشاشة الهيكلية الرئيسية (Main Navigation Shell)
/// تجمع بين شريط التنقل السفلي (Bottom Navigation Bar)
/// والمشغل المصغر العائم الدائم (Persistent Floating MiniPlayer)
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages = [
    const HomeScreen(),
    const PlaylistsScreen(),
    SleepTimerScreen(onBackPressed: () => _switchToTab(0)),
    SettingsScreen(onBackPressed: () => _switchToTab(0)),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isAr = settingsState.isArabic;

        return PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            // إذا كان المستخدم في أي تبويب آخر غير Home، فإن الرجوع يعيده أولاً للشاشة الرئيسية
            if (_currentIndex != 0) {
              _switchToTab(0);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Stack(
              children: [
                // عرض الشاشة الحالية
                IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),

                // المشغل المصغر العائم المستمر فوق شريط التنقل السفلي
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MiniPlayer(),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg(context),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(AppColors.isDark ? 80 : 12),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: AppColors.primaryBlue,
                      unselectedItemColor: AppColors.isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                      items: [
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.home_filled),
                          label: isAr ? 'الرئيسية' : 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.queue_music_rounded),
                          label: isAr ? 'قوائم التشغيل' : 'Playlists',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.timer_outlined),
                          label: isAr ? 'المؤقت' : 'Timer',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.settings),
                          label: isAr ? 'الإعدادات' : 'Settings',
                        ),
                      ],
                    ),
                    const AppDeveloperFooter(
                      showDivider: true,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

