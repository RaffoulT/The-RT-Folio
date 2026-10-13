import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilmImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const FilmImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    final cleanPath = path.trim();

    if (cleanPath.isEmpty) {
      content = _buildPlaceholder();
    } else if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      content = Image.network(
        cleanPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (cleanPath.startsWith('/') || cleanPath.contains(':\\')) {
      content = Image.file(
        File(cleanPath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      // Asset path
      String assetPath = cleanPath;
      if (!assetPath.startsWith('assets/')) {
        assetPath = 'assets/$assetPath';
      }

      // Check if .avif and provide automatic .jpg fallback attempt
      final fallbackPath = assetPath.endsWith('.avif') 
          ? assetPath.replaceAll('.avif', '.jpg') 
          : null;

      content = Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (fallbackPath != null) {
            return Image.asset(
              fallbackPath,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (c, e, s) => _buildPlaceholder(),
            );
          }
          return _buildPlaceholder();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }
    return content;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.surfaceHighlight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 28,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              'FILM FRAME',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 1.5,
                color: AppTheme.textMuted.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
