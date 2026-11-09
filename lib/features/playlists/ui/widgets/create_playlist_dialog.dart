import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_styles.dart';
import '../../../../core/utils/constants/assets_keys.dart';

/// خيار غلاف قائمة التشغيل
class CoverPresetOption {
  final String label;
  final String? url;
  final bool isGradient;

  const CoverPresetOption({
    required this.label,
    this.url,
    this.isGradient = false,
  });
}

/// نافذة إنشاء وتعديل قائمة التشغيل مع إمكانية تعيين الغلاف (Create & Edit Playlist Dialog)
class CreatePlaylistDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialCoverUrl;
  final bool initialIsGradient;
  final bool isEdit;
  final void Function(String title, String? coverUrl, bool isGradient) onSave;

  const CreatePlaylistDialog({
    super.key,
    this.initialTitle,
    this.initialCoverUrl,
    this.initialIsGradient = false,
    this.isEdit = false,
    required this.onSave,
  });

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  late final TextEditingController _controller;
  late bool _isGradient;
  late String? _selectedCoverUrl;

  final List<CoverPresetOption> _coverPresets = const [
    CoverPresetOption(label: 'Gradient Neon', isGradient: true),
    CoverPresetOption(label: 'Chill Sunset', url: AssetsKeys.chillVibesCover),
    CoverPresetOption(label: 'Workout Energy', url: AssetsKeys.workoutMixCover),
    CoverPresetOption(label: 'Neon Drops', url: AssetsKeys.recentlyAddedCover),
    CoverPresetOption(label: 'Midnight City', url: AssetsKeys.midnightCityCover),
    CoverPresetOption(label: 'Ocean Waves', url: AssetsKeys.coastalWavesCover),
    CoverPresetOption(label: 'Night Forest', url: AssetsKeys.nightcallCover),
    CoverPresetOption(label: 'Concert Lights', url: AssetsKeys.levitatingCover),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle ?? '');
    _isGradient = widget.initialIsGradient;
    _selectedCoverUrl = widget.initialCoverUrl ?? (_isGradient ? null : AssetsKeys.recentlyAddedCover);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardBg(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان النافذة
              Row(
                children: [
                  Icon(
                    widget.isEdit ? Icons.edit_note_rounded : Icons.playlist_add_rounded,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isEdit
                        ? (isAr ? 'تعديل قائمة التشغيل' : 'Edit Playlist')
                        : (isAr ? 'إنشاء قائمة جديدة' : 'New Playlist'),
                    style: AppStyles.font22Bold,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // حقل إدخال اسم القائمة
              Text(
                isAr ? 'اسم القائمة' : 'Playlist Name',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryColor(context),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                autofocus: !widget.isEdit,
                style: TextStyle(color: AppColors.textPrimaryColor(context)),
                decoration: InputDecoration(
                  hintText: isAr ? 'أدخل اسم قائمة التشغيل...' : 'Enter playlist title...',
                  hintStyle: TextStyle(color: AppColors.textSecondaryColor(context)),
                  filled: true,
                  fillColor: AppColors.isDark ? const Color(0xFF1E2538) : AppColors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 22),

              // قسم اختيار الغلاف
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'اختر غلاف القائمة' : 'Choose Cover Artwork',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryColor(context),
                    ),
                  ),
                  if (_isGradient)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.vibrantViolet.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAr ? 'تدرج بنفسجي' : 'Gradient',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.vibrantViolet,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // شريط شبكة الأغلفة للاختيار السريع
              SizedBox(
                height: 94,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _coverPresets.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final preset = _coverPresets[index];
                    final isSelected = preset.isGradient
                        ? _isGradient
                        : (!_isGradient && _selectedCoverUrl == preset.url);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _isGradient = preset.isGradient;
                          _selectedCoverUrl = preset.url;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                            width: 3.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withAlpha(120),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                          gradient: preset.isGradient ? AppColors.favoritesGradient : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Stack(
                            children: [
                              if (!preset.isGradient && preset.url != null)
                                Positioned.fill(
                                  child: Image.network(
                                    preset.url!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFF1E2538),
                                      child: const Icon(Icons.album, color: Colors.white),
                                    ),
                                  ),
                                ),

                              if (preset.isGradient)
                                const Center(
                                  child: Icon(Icons.favorite, color: Colors.white, size: 28),
                                ),

                              // شارة الاختيار (Checkmark)
                              if (isSelected)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryBlue,
                                    ),
                                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 26),

              // أزرار الحفظ والإلغاء
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      isAr ? 'إلغاء' : 'Cancel',
                      style: TextStyle(color: AppColors.textSecondaryColor(context)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    ),
                    onPressed: () {
                      final title = _controller.text.trim();
                      if (title.isNotEmpty) {
                        widget.onSave(title, _selectedCoverUrl, _isGradient);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      widget.isEdit
                          ? (isAr ? 'حفظ التعديل' : 'Save Changes')
                          : (isAr ? 'إنشاء' : 'Create'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
