import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AVoxHeader extends StatelessWidget {
  final String? badgeText;
  final Widget? leading;

  const AVoxHeader({super.key, this.badgeText, this.leading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          leading ??
              Icon(Icons.menu, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Text(
            'aVox',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (badgeText != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.45)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    badgeText!,
                    style: GoogleFonts.inter(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.shield_outlined,
                      color: AppColors.secondary, size: 15),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Centered header for modal-style screens (searching, rating)
class CenteredHeader extends StatelessWidget {
  final String title;
  final Color titleColor;
  final VoidCallback? onClose;

  const CenteredHeader({
    super.key,
    required this.title,
    this.titleColor = AppColors.secondary,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onClose ?? () => Navigator.pop(context),
              child: const Icon(Icons.close,
                  color: AppColors.textSecondary, size: 22),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
