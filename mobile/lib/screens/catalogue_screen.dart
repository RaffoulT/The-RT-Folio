import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/roll_card.dart';
import '../services/catalogue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/film_card_view.dart';
import 'admin_edit_screen.dart';
import 'roll_gallery_screen.dart';

class CatalogueScreen extends StatefulWidget {
  final CatalogueService catalogueService;

  const CatalogueScreen({super.key, required this.catalogueService});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  List<RollCard> _allCards = [];
  String _selectedFilter = 'all'; // 'all', 'series', 'session'
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    final cards = await widget.catalogueService.getCards(
      forceRefresh: forceRefresh,
    );
    if (mounted) {
      setState(() {
        _allCards = cards;
        _isLoading = false;
      });
    }
  }

  List<RollCard> get _filteredCards {
    return _allCards.where((card) {
      final matchesFilter =
          _selectedFilter == 'all' ||
          card.category.toLowerCase() == _selectedFilter.toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty ||
          card.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (card.format?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (card.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _openRollGallery(RollCard card) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RollGalleryScreen(card: card)));
  }

  void _openAdminEdit([RollCard? card]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminEditScreen(
          catalogueService: widget.catalogueService,
          existingCard: card,
        ),
      ),
    );
    if (changed == true) {
      _loadCards(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RT.CAPTURED.ON.FILM',
              style: GoogleFonts.spaceMono(
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              'Photography Catalogue',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add Roll',
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppTheme.goldAccent,
            ),
            onPressed: () => _openAdminEdit(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.goldAccent,
        backgroundColor: AppTheme.surface,
        onRefresh: () => _loadCards(forceRefresh: true),
        child: Column(
          children: [
            // Search & Filter Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              color: AppTheme.background,
              child: Column(
                children: [
                  // Search Box
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search rolls, format, location...',
                      hintStyle: GoogleFonts.inter(
                        color: AppTheme.textSubtle,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppTheme.textMuted,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.surfaceBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.surfaceBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.goldAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips
                  Row(
                    children: [
                      _buildFilterChip('ALL', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('SERIES', 'series'),
                      const SizedBox(width: 8),
                      _buildFilterChip('SESSION', 'session'),
                    ],
                  ),
                ],
              ),
            ),

            // Catalogue Rolls List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.goldAccent,
                      ),
                    )
                  : _filteredCards.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_roll_outlined,
                            size: 48,
                            color: AppTheme.textSubtle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No rolls found.',
                            style: GoogleFonts.spaceMono(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: _filteredCards.length,
                      itemBuilder: (context, index) {
                        final card = _filteredCards[index];
                        return FilmCardView(
                          card: card,
                          onTap: () => _openRollGallery(card),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldAccent.withValues(alpha: 0.18)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppTheme.goldAccent : AppTheme.surfaceBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceMono(
            color: isSelected ? AppTheme.goldAccent : AppTheme.textMuted,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
