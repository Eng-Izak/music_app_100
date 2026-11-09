import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_styles.dart';
import '../../../../core/shared/models/user_profile_model.dart';

/// ترويسة الملف الشخصي في شاشة الإعدادات (Profile Header)
/// تعرض الصورة الدائرية، الاسم، البريد الإلكتروني، وزر "Edit Profile"
class ProfileHeader extends StatelessWidget {
  final UserProfileModel userProfile;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.userProfile,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الصورة الدائرية مع زر التعديل الدائري الأزرق في الركن
        GestureDetector(
          onTap: onEditProfile,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFECE6), // بيج مائل للرمادي ناعم جداً كما في الصورة
                  border: Border.all(
                    color: AppColors.isDark ? const Color(0xFF333752) : const Color(0xFFE2E8F0),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(AppColors.isDark ? 80 : 15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: ClipOval(
                  child: Image.network(
                    userProfile.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      size: 64,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              // شارة القلم الدائرية الزرقاء في أسفل يمين الصورة
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue,
                    border: Border.all(
                      color: AppColors.isDark ? const Color(0xFF0F101E) : Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withAlpha(100),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // الاسم الكامل (Alex Rivera)
        Text(
          userProfile.name,
          style: AppStyles.font22Bold.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        // شارة المستوى والبريد الإلكتروني (LOCAL EXPLORER • email)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'LOCAL EXPLORER',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.6,
              ),
            ),
            const Text(
              ' • ',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Flexible(
              child: Text(
                userProfile.email,
                style: TextStyle(
                  color: AppColors.isDark ? const Color(0xFF8E9AA8) : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

