/// Model for cat images from CATAAS (Cat as a Service)
///
/// API: https://cataas.com
class CataasImage {
  final String id;
  final String imageUrl;
  final List<String> tags;
  final String? text;
  final int? width;
  final int? height;

  const CataasImage({
    required this.id,
    required this.imageUrl,
    this.tags = const [],
    this.text,
    this.width,
    this.height,
  });

  /// Create from CATAAS API JSON response
  factory CataasImage.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] as String;
    return CataasImage(
      id: id,
      imageUrl: 'https://cataas.com/cat/$id',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  /// Generate URL for a random cat image
  static String randomImageUrl({
    String? tag,
    String? text,
    int? fontSize,
    String? fontColor,
    String? filter,
    String? type,
    int? width,
    int? height,
  }) {
    final segments = <String>['https://cataas.com/cat'];

    // Add tag if specified
    if (tag != null && tag.isNotEmpty) {
      segments.add(tag);
    }

    // Add gif if requested
    final path = segments.join('/');

    // Build query parameters
    final queryParams = <String, String>{};

    if (text != null && text.isNotEmpty) {
      // Use says endpoint for text overlay
      final textPath = '$path/says/${Uri.encodeComponent(text)}';
      if (fontSize != null) queryParams['fontSize'] = fontSize.toString();
      if (fontColor != null) queryParams['fontColor'] = fontColor;
      if (filter != null) queryParams['filter'] = filter;
      if (type != null) queryParams['type'] = type;
      if (width != null) queryParams['width'] = width.toString();
      if (height != null) queryParams['height'] = height.toString();

      if (queryParams.isEmpty) return textPath;
      return '$textPath?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    if (filter != null) queryParams['filter'] = filter;
    if (type != null) queryParams['type'] = type;
    if (width != null) queryParams['width'] = width.toString();
    if (height != null) queryParams['height'] = height.toString();

    if (queryParams.isEmpty) return path;
    return '$path?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  /// Generate URL for a random GIF cat
  static String randomGifUrl() => 'https://cataas.com/cat/gif';

  @override
  String toString() => 'CataasImage(id: $id, tags: $tags)';
}

/// Available image filters for CATAAS
enum CataasFilter {
  blur,
  mono,
  negate,
  custom,
}

/// Available image types/sizes for CATAAS
enum CataasType {
  xsmall,
  small,
  medium,
  square,
}
