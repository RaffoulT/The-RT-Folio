import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/roll_card.dart';
import '../services/catalogue_service.dart';
import '../theme/app_theme.dart';
import '../widgets/film_image.dart';

class AdminEditScreen extends StatefulWidget {
  final CatalogueService catalogueService;
  final RollCard? existingCard;

  const AdminEditScreen({
    super.key,
    required this.catalogueService,
    this.existingCard,
  });

  @override
  State<AdminEditScreen> createState() => _AdminEditScreenState();
}

class _AdminEditScreenState extends State<AdminEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _codeController;
  late TextEditingController _titleController;
  late TextEditingController _formatController;
  late TextEditingController _locationController;
  late TextEditingController _yearController;
  late TextEditingController _descriptionController;

  String _category = 'series';
  String _coverImagePath = '';
  List<RollPhoto> _photos = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final card = widget.existingCard;
    _codeController = TextEditingController(text: card?.code ?? 'ROLL — ');
    _titleController = TextEditingController(text: card?.title ?? '');
    _formatController = TextEditingController(
      text: card?.format ?? '35mm Film',
    );
    _locationController = TextEditingController(
      text: card?.location ?? 'Beirut, LB',
    );
    _yearController = TextEditingController(
      text: card?.year ?? DateTime.now().year.toString(),
    );
    _descriptionController = TextEditingController(
      text: card?.description ?? '',
    );
    _category = card?.category ?? 'series';
    _coverImagePath = card?.image ?? '';
    _photos = card != null ? List.from(card.photos) : [];
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _formatController.dispose();
    _locationController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _coverImagePath = file.path);
    }
  }

  Future<void> _addPhotoFromPicker() async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty) {
      setState(() {
        for (int i = 0; i < files.length; i++) {
          _photos.add(
            RollPhoto(
              image: files[i].path,
              caption:
                  'Frame ${(_photos.length + 1).toString().padLeft(2, '0')}',
            ),
          );
        }
      });
    }
  }

  Future<void> _saveRoll() async {
    if (!_formKey.currentState!.validate()) return;
    if (_coverImagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cover image for this roll.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final roll = RollCard(
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      category: _category,
      image: _coverImagePath,
      format: _formatController.text.trim(),
      location: _locationController.text.trim(),
      year: _yearController.text.trim(),
      description: _descriptionController.text.trim(),
      photos: _photos,
      isUserCreated: true,
    );

    await widget.catalogueService.saveCustomCard(roll);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "${roll.title}" to catalogue!')),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCard == null ? 'ADD NEW ROLL' : 'EDIT ROLL'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveRoll,
            icon: _isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: AppTheme.goldAccent),
            label: Text(
              'SAVE',
              style: GoogleFonts.spaceMono(
                color: AppTheme.goldAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Cover Image Picker
            GestureDetector(
              onTap: _pickCoverImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: _coverImagePath.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          FilmImage(path: _coverImagePath, fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'TAP TO CHANGE',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 10,
                                  color: AppTheme.goldAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 38,
                            color: AppTheme.goldAccent,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CHOOSE COVER IMAGE',
                            style: GoogleFonts.spaceMono(
                              color: AppTheme.goldAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Roll Code & Category Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Roll Code',
                      hintText: 'ROLL — 03',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _category,
                  dropdownColor: AppTheme.surface,
                  items: const [
                    DropdownMenuItem(value: 'series', child: Text('Series')),
                    DropdownMenuItem(value: 'session', child: Text('Session')),
                  ],
                  onChanged: (val) =>
                      setState(() => _category = val ?? 'series'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Roll Title',
                hintText: 'e.g., Kodak Portra 400',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Format & Location
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _formatController,
                    decoration: const InputDecoration(
                      labelText: 'Film Format',
                      hintText: '35mm Film',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Beirut, LB',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Year & Description
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: '2026',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description / Notes',
                hintText: 'Notes about the roll, mood, or lighting...',
              ),
            ),
            const SizedBox(height: 28),

            // Multi-Photo Gallery Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GALLERY FRAMES (${_photos.length})',
                  style: GoogleFonts.spaceMono(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _addPhotoFromPicker,
                  icon: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.goldAccent,
                  ),
                  label: Text(
                    'ADD PHOTOS',
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      color: AppTheme.goldAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_photos.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Center(
                  child: Text(
                    'No photos added to this roll yet.\nTap "ADD PHOTOS" to pick from device.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: FilmImage(
                            path: photo.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            photo.caption ?? 'Frame ${index + 1}',
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppTheme.warmRed,
                          ),
                          onPressed: () {
                            setState(() => _photos.removeAt(index));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
