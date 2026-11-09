import 'package:flutter/material.dart';
import '../../../../core/theming/app_colors.dart';

/// بطاقة غلاف الألبوم النيومورفيك مع تأثير الظل الناعم (Vinyl / Album Artwork Card)
/// تطابق البطاقة البارزة في الصورة #1 بحدودها الدائرية الكبيرة وظلالها المتقنة
class VinylArtworkCard extends StatelessWidget {
  final String imageUrl;

  const VinylArtworkCard({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cardSize = MediaQuery.of(context).size.width * 0.78;

    return Center(
      child: Container(
        width: cardSize,
        height: cardSize,
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(38),
          boxShadow: AppColors.isDark
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E2538).withAlpha(160),
                    blurRadius: 36,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  // الظل الخارجي المضيء والناعم
                  BoxShadow(
                    color: const Color(0xFF94A3B8).withAlpha(45),
                    blurRadius: 30,
                    spreadRadius: 8,
                    offset: const Offset(0, 14),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.isDark ? const Color(0xFF161F30) : const Color(0xFF2E1065),
              child: Center(
                child: Icon(
                  Icons.album,
                  size: 70,
                  color: AppColors.isDark ? AppColors.primaryBlue : AppColors.vibrantViolet,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

