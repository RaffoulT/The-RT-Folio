import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/roll_card.dart';
import '../theme/app_theme.dart';
import '../widgets/film_badge.dart';
import '../widgets/film_image.dart';

class RollGalleryScreen extends StatefulWidget {
  final RollCard card;

  const RollGalleryScreen({
    super.key,
    required this.card,
  });

  @override
  State<RollGalleryScreen> createState() => _RollGalleryScreenState();
}

class _RollGalleryScreenState extends State<RollGalleryScreen> {
  bool _isGridView = true;

  void _openLightbox(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LightboxScreen(
          photos: widget.card.photos,
          initialIndex: initialIndex,
          rollTitle: widget.card.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final photos = card.photos;

    return Scaffold(
      appBar: AppBar(
        title: Text(card.code),
        actions: [
          IconButton(
            tooltip: _isGridView ? 'List View' : 'Grid View',
            icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Roll Metadata Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.goldAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          card.code,
                          style: GoogleFonts.spaceMono(
                            color: AppTheme.goldAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilmBadge(label: card.category),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.title,
                    style: GoogleFonts.spaceMono(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (card.description != null && card.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      card.description!,
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (card.format != null)
                        FilmBadge(label: card.format!, icon: Icons.camera_roll_outlined),
                      if (card.location != null)
                        FilmBadge(label: card.location!, icon: Icons.location_on_outlined),
                      if (card.year != null)
                        FilmBadge(label: card.year!, icon: Icons.calendar_today_outlined),
                      FilmBadge(
                        label: '${photos.length} FRAMES',
                        icon: Icons.photo_library_outlined,
                        color: AppTheme.goldAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.surfaceBorder, height: 1),
                ],
              ),
            ),
          ),

          // Photos Grid or List
          if (photos.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_outlined, size: 40, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'No frames added to this roll yet.',
                      style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else if (_isGridView)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final photo = photos[index];
                    return GestureDetector(
                      onTap: () => _openLightbox(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: FilmImage(
                                path: photo.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              color: AppTheme.surface,
                              child: Row(
                                children: [
                                  Text(
                                    '${index + 1}'.padLeft(2, '0'),
                                    style: GoogleFonts.spaceMono(
                                      color: AppTheme.goldAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      photo.caption ?? 'Frame ${index + 1}',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: photos.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final photo = photos[index];
                    return GestureDetector(
                      onTap: () => _openLightbox(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 4 / 3,
                              child: FilmImage(
                                path: photo.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      photo.caption ?? 'Frame ${index + 1}',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'FRAME ${(index + 1).toString().padLeft(2, '0')}',
                                    style: GoogleFonts.spaceMono(
                                      color: AppTheme.goldAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: photos.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _LightboxScreen extends StatefulWidget {
  final List<RollPhoto> photos;
  final int initialIndex;
  final String rollTitle;

  const _LightboxScreen({
    required this.photos,
    required this.initialIndex,
    required this.rollTitle,
  });

  @override
  State<_LightboxScreen> createState() => _LightboxScreenState();
}

class _LightboxScreenState extends State<_LightboxScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: GoogleFonts.spaceMono(fontSize: 14, color: AppTheme.textPrimary),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              return Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: FilmImage(
                    path: photo.image,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          // Caption Bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              color: Colors.black.withValues(alpha: 0.75),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EXP ${_currentIndex + 1}',
                        style: GoogleFonts.spaceMono(
                          color: AppTheme.goldAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.rollTitle,
                        style: GoogleFonts.spaceMono(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (currentPhoto.caption != null && currentPhoto.caption!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      currentPhoto.caption!,
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
