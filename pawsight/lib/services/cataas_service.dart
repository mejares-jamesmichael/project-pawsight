import '../models/cataas_image.dart';
import 'base_api_service.dart';

/// Service for fetching cat images from CATAAS (Cat as a Service)
///
/// API: https://cataas.com
/// Features:
/// - Random cat images
/// - Images with text overlay
/// - GIF cats
/// - Tagged/filtered images
class CataasService extends BaseApiService {
  @override
  String get baseUrl => 'https://cataas.com';

  static final CataasService _instance = CataasService._internal();

  factory CataasService() => _instance;

  CataasService._internal();

  /// Get all available tags
  Future<List<String>> getTags() async {
    final response = await get('/api/tags');

    if (response is List) {
      return response.cast<String>();
    }

    throw ApiException('Invalid response format from CATAAS tags API');
  }

  /// Get cats with optional filtering
  ///
  /// [tags] - Filter by tags (comma-separated)
  /// [skip] - Number of results to skip (pagination)
  /// [limit] - Maximum number of results (default 10)
  Future<List<CataasImage>> getCats({
    List<String>? tags,
    int skip = 0,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    if (tags != null && tags.isNotEmpty) {
      queryParams['tags'] = tags.join(',');
    }

    final response = await get('/api/cats', queryParams: queryParams);

    if (response is List) {
      return response
          .map((json) => CataasImage.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ApiException('Invalid response format from CATAAS API');
  }

  /// Get URL for a random cat image
  ///
  /// [tag] - Optional tag to filter (e.g., 'cute', 'orange')
  /// [text] - Optional text to overlay on image
  /// [fontSize] - Font size for text overlay
  /// [fontColor] - Font color for text overlay
  /// [filter] - Image filter (blur, mono, negate, custom)
  /// [type] - Image size type (xsmall, small, medium, square)
  /// [width] - Custom width
  /// [height] - Custom height
  String getRandomCatUrl({
    String? tag,
    String? text,
    int? fontSize,
    String? fontColor,
    String? filter,
    String? type,
    int? width,
    int? height,
  }) {
    return CataasImage.randomImageUrl(
      tag: tag,
      text: text,
      fontSize: fontSize,
      fontColor: fontColor,
      filter: filter,
      type: type,
      width: width,
      height: height,
    );
  }

  /// Get URL for a random GIF cat
  String getRandomGifUrl() => CataasImage.randomGifUrl();

  /// Get URL for a cat saying something
  ///
  /// [text] - Text for the cat to "say"
  /// [tag] - Optional tag filter
  /// [fontSize] - Font size (default varies)
  /// [fontColor] - Font color (e.g., 'white', 'orange', '#FF5500')
  String getCatSaysUrl(
    String text, {
    String? tag,
    int? fontSize,
    String? fontColor,
  }) {
    return CataasImage.randomImageUrl(
      tag: tag,
      text: text,
      fontSize: fontSize,
      fontColor: fontColor,
    );
  }

  /// Get URL for a cat image by ID
  String getCatImageUrl(String id) => '$baseUrl/cat/$id';

  /// Get raw image bytes for a random cat
  Future<List<int>> getRandomCatBytes({String? tag}) async {
    final endpoint = tag != null ? '/cat/$tag' : '/cat';
    return await getBytes(endpoint);
  }
}
