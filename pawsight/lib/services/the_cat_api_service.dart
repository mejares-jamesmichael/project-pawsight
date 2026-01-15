import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/cat_breed.dart';
import 'base_api_service.dart';

/// Service for TheCatAPI - cat images and breed information
///
/// API: https://api.thecatapi.com
/// Features:
/// - Random cat images
/// - Cat breed information
/// - Images filtered by breed
/// - High-quality cat photos
class TheCatApiService extends BaseApiService {
  @override
  String get baseUrl => 'https://api.thecatapi.com/v1';

  @override
  Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'x-api-key': _apiKey,
      };

  /// Get API key from environment variables
  static String get _apiKey {
    final key = dotenv.env['THE_CAT_API_KEY'];
    if (key == null || key.isEmpty) {
      // Return empty string - API works without key but with limitations
      return '';
    }
    return key;
  }

  static final TheCatApiService _instance = TheCatApiService._internal();

  factory TheCatApiService() => _instance;

  TheCatApiService._internal();

  /// Check if API key is configured
  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Get random cat images
  ///
  /// [limit] - Number of images (1-100, default 1, max 10 without API key)
  /// [hasBreeds] - Only return images with breed info
  /// [breedIds] - Filter by breed IDs (e.g., ['beng', 'abys'])
  /// [categoryIds] - Filter by category IDs
  Future<List<TheCatApiImage>> getRandomImages({
    int limit = 1,
    bool hasBreeds = false,
    List<String>? breedIds,
    List<int>? categoryIds,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.clamp(1, hasApiKey ? 100 : 10).toString(),
    };

    if (hasBreeds) {
      queryParams['has_breeds'] = '1';
    }

    if (breedIds != null && breedIds.isNotEmpty) {
      queryParams['breed_ids'] = breedIds.join(',');
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      queryParams['category_ids'] = categoryIds.join(',');
    }

    final response = await get('/images/search', queryParams: queryParams);

    if (response is List) {
      return response
          .map((json) => TheCatApiImage.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ApiException('Invalid response format from TheCatAPI');
  }

  /// Get a single random cat image
  Future<TheCatApiImage> getRandomImage({
    bool hasBreeds = false,
    String? breedId,
  }) async {
    final images = await getRandomImages(
      limit: 1,
      hasBreeds: hasBreeds,
      breedIds: breedId != null ? [breedId] : null,
    );
    return images.first;
  }

  /// Get an image by its ID
  Future<TheCatApiImage> getImageById(String imageId) async {
    final response = await get('/images/$imageId');

    if (response is Map<String, dynamic>) {
      return TheCatApiImage.fromJson(response);
    }

    throw ApiException('Invalid response format');
  }

  /// Get all cat breeds
  ///
  /// [limit] - Number of breeds per page
  /// [page] - Page number (0-based)
  Future<List<CatBreed>> getBreeds({
    int? limit,
    int? page,
  }) async {
    final queryParams = <String, String>{};

    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }

    final response = await get('/breeds', queryParams: queryParams);

    if (response is List) {
      return response
          .map((json) => CatBreed.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ApiException('Invalid response format from TheCatAPI breeds');
  }

  /// Get a breed by its ID
  Future<CatBreed> getBreedById(String breedId) async {
    final response = await get('/breeds/$breedId');

    if (response is Map<String, dynamic>) {
      return CatBreed.fromJson(response);
    }

    throw ApiException('Invalid response format');
  }

  /// Search breeds by name
  Future<List<CatBreed>> searchBreeds(String query) async {
    final response = await get('/breeds/search', queryParams: {'q': query});

    if (response is List) {
      return response
          .map((json) => CatBreed.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ApiException('Invalid response format from breed search');
  }

  /// Get images for a specific breed
  Future<List<TheCatApiImage>> getBreedImages(
    String breedId, {
    int limit = 10,
  }) async {
    return await getRandomImages(
      limit: limit,
      breedIds: [breedId],
    );
  }

  /// Get available image categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await get('/categories');

    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }

    throw ApiException('Invalid response format from categories');
  }
}
