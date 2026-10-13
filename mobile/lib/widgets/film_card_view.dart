import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/roll_card.dart';
import '../theme/app_theme.dart';
import 'film_badge.dart';
import 'film_image.dart';

class FilmCardView extends StatelessWidget {
  final RollCard card;
  final VoidCallback onTap;

  const FilmCardView({
    super.key,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Roll Code & Category
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: card.category == 'series' 
                              ? AppTheme.goldAccent 
                              : AppTheme.warmRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        card.code,
                        style: GoogleFonts.spaceMono(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  FilmBadge(
                    label: card.category,
                    color: card.category == 'series' 
                        ? AppTheme.goldAccent 
                        : AppTheme.warmRed,
                  ),
                ],
              ),
            ),

            // Cover Image
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FilmImage(
                    path: card.image,
                    fit: BoxFit.cover,
                  ),
                  // Film frame edge markings overlay
                  Positioned(
                    top: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        card.frameNum != null ? 'EXP. ${card.frameNum}' : 'FRAME',
                        style: GoogleFonts.spaceMono(
                          color: AppTheme.goldAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (card.photos.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 12, color: AppTheme.textPrimary),
                            const SizedBox(width: 5),
                            Text(
                              '${card.photos.length} frames',
                              style: GoogleFonts.spaceMono(
                                color: AppTheme.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: GoogleFonts.spaceMono(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (card.description != null && card.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      card.description!,
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Metadata Badges Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (card.format != null)
                        FilmBadge(label: card.format!, icon: Icons.camera_roll_outlined),
                      if (card.location != null)
                        FilmBadge(label: card.location!, icon: Icons.location_on_outlined),
                      if (card.year != null)
                        FilmBadge(label: card.year!, icon: Icons.calendar_today_outlined),
                    ],
                  ),
                  
                  const SizedBox(height: 14),
                  const Divider(color: AppTheme.surfaceBorder, height: 1),
                  const SizedBox(height: 12),

                  // Footer link row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'OPEN ROLL GALLERY',
                        style: GoogleFonts.spaceMono(
                          color: AppTheme.goldAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppTheme.goldAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
