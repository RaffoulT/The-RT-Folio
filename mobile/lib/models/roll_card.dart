
class RollPhoto {
  final String image;
  final String? caption;
  final String? alt;
  final String? orientation;

  RollPhoto({
    required this.image,
    this.caption,
    this.alt,
    this.orientation,
  });

  factory RollPhoto.fromJson(Map<String, dynamic> json) {
    return RollPhoto(
      image: json['image'] as String? ?? '',
      caption: json['caption'] as String?,
      alt: json['alt'] as String?,
      orientation: json['orientation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      if (caption != null) 'caption': caption,
      if (alt != null) 'alt': alt,
      if (orientation != null) 'orientation': orientation,
    };
  }

  /// Normalizes asset or local path
  String get assetPath {
    if (image.startsWith('assets/')) return image;
    if (image.startsWith('images/')) return 'assets/$image';
    return image;
  }

  bool get isLocalFile => image.startsWith('/') || image.contains(':\\') || image.startsWith('file://');
}

class RollCard {
  final String code;
  final String category; // 'series' or 'session'
  final String title;
  final String image;
  final String? alt;
  final String? frameNum;
  final String? location;
  final String? year;
  final String? format;
  final String? description;
  final String? link;
  final String? linkText;
  final List<RollPhoto> photos;
  final bool isUserCreated;

  RollCard({
    required this.code,
    required this.category,
    required this.title,
    required this.image,
    this.alt,
    this.frameNum,
    this.location,
    this.year,
    this.format,
    this.description,
    this.link,
    this.linkText,
    this.photos = const [],
    this.isUserCreated = false,
  });

  factory RollCard.fromJson(Map<String, dynamic> json, {bool isUserCreated = false}) {
    final rawPhotos = json['photos'] as List<dynamic>? ?? [];
    return RollCard(
      code: json['code'] as String? ?? 'ROLL',
      category: (json['category'] as String? ?? 'series').toLowerCase(),
      title: json['title'] as String? ?? 'Untitled Roll',
      image: json['image'] as String? ?? '',
      alt: json['alt'] as String?,
      frameNum: json['frameNum'] as String?,
      location: json['location'] as String?,
      year: json['year'] as String?,
      format: json['format'] as String?,
      description: json['description'] as String?,
      link: json['link'] as String?,
      linkText: json['linkText'] as String?,
      photos: rawPhotos.map((p) => RollPhoto.fromJson(p as Map<String, dynamic>)).toList(),
      isUserCreated: isUserCreated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'category': category,
      'title': title,
      'image': image,
      if (alt != null) 'alt': alt,
      if (frameNum != null) 'frameNum': frameNum,
      if (location != null) 'location': location,
      if (year != null) 'year': year,
      if (format != null) 'format': format,
      if (description != null) 'description': description,
      if (link != null) 'link': link,
      if (linkText != null) 'linkText': linkText,
      'photos': photos.map((p) => p.toJson()).toList(),
      'isUserCreated': isUserCreated,
    };
  }

  String get assetPath {
    if (image.startsWith('assets/')) return image;
    if (image.startsWith('images/')) return 'assets/$image';
    return image;
  }

  bool get isLocalFile => image.startsWith('/') || image.contains(':\\') || image.startsWith('file://');
}
