import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/cat_breed.dart';
import '../models/cat_fact.dart';
import '../models/http_cat_image.dart';
import '../services/base_api_service.dart';
import '../services/cat_facts_service.dart';
import '../services/cataas_service.dart';
import '../services/http_cat_service.dart';
import '../services/the_cat_api_service.dart';

/// Provider for managing cat-related API data and state
///
/// Centralizes access to:
/// - Cat facts (cat-fact.herokuapp.com, meowfacts)
/// - Cat images (CATAAS, TheCatAPI)
/// - Cat breeds (TheCatAPI)
/// - HTTP status cats (http.cat)
class CatApiProvider extends ChangeNotifier {
  final CatFactsService _factsService = CatFactsService();
  final CataasService _cataasService = CataasService();
  final TheCatApiService _theCatApiService = TheCatApiService();
  final HttpCatService _httpCatService = HttpCatService();

  // State
  List<CatFact> _facts = [];
  List<CatBreed> _breeds = [];
  List<TheCatApiImage> _catImages = [];
  List<String> _cataaTags = [];
  CatFact? _currentFact;
  TheCatApiImage? _currentImage;
  CatBreed? _selectedBreed;

  bool _isLoadingFacts = false;
  bool _isLoadingBreeds = false;
  bool _isLoadingImages = false;
  String? _error;

  // Getters
  UnmodifiableListView<CatFact> get facts => UnmodifiableListView(_facts);
  UnmodifiableListView<CatBreed> get breeds => UnmodifiableListView(_breeds);
  UnmodifiableListView<TheCatApiImage> get catImages =>
      UnmodifiableListView(_catImages);
  UnmodifiableListView<String> get cataasTags =>
      UnmodifiableListView(_cataaTags);

  CatFact? get currentFact => _currentFact;
  TheCatApiImage? get currentImage => _currentImage;
  CatBreed? get selectedBreed => _selectedBreed;

  bool get isLoadingFacts => _isLoadingFacts;
  bool get isLoadingBreeds => _isLoadingBreeds;
  bool get isLoadingImages => _isLoadingImages;
  bool get isLoading => _isLoadingFacts || _isLoadingBreeds || _isLoadingImages;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Check if TheCatAPI key is configured
  bool get hasTheCatApiKey => _theCatApiService.hasApiKey;

  // ============================================
  // CAT FACTS
  // ============================================

  /// Load random cat facts
  Future<void> loadRandomFacts({int amount = 5}) async {
    _isLoadingFacts = true;
    _error = null;
    notifyListeners();

    try {
      _facts = await _factsService.getRandomFacts(amount: amount);
      if (_facts.isNotEmpty) {
        _currentFact = _facts.first;
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load cat facts';
    } finally {
      _isLoadingFacts = false;
      notifyListeners();
    }
  }

  /// Get a new random fact
  Future<void> refreshFact() async {
    _isLoadingFacts = true;
    _error = null;
    notifyListeners();

    try {
      _currentFact = await _factsService.getRandomFact();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load cat fact';
    } finally {
      _isLoadingFacts = false;
      notifyListeners();
    }
  }

  // ============================================
  // CAT BREEDS (TheCatAPI)
  // ============================================

  /// Load all cat breeds
  Future<void> loadBreeds() async {
    if (_breeds.isNotEmpty) return; // Already loaded

    _isLoadingBreeds = true;
    _error = null;
    notifyListeners();

    try {
      _breeds = await _theCatApiService.getBreeds();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load cat breeds';
    } finally {
      _isLoadingBreeds = false;
      notifyListeners();
    }
  }

  /// Select a breed and load its images
  Future<void> selectBreed(CatBreed breed) async {
    _selectedBreed = breed;
    notifyListeners();

    await loadBreedImages(breed.id);
  }

  /// Clear selected breed
  void clearSelectedBreed() {
    _selectedBreed = null;
    notifyListeners();
  }

  /// Search breeds by name
  Future<List<CatBreed>> searchBreeds(String query) async {
    if (query.isEmpty) return _breeds;

    try {
      return await _theCatApiService.searchBreeds(query);
    } catch (e) {
      // Fall back to local filtering
      final lowerQuery = query.toLowerCase();
      return _breeds
          .where((breed) =>
              breed.name.toLowerCase().contains(lowerQuery) ||
              (breed.temperament?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    }
  }

  // ============================================
  // CAT IMAGES (TheCatAPI)
  // ============================================

  /// Load random cat images
  Future<void> loadRandomImages({
    int limit = 10,
    bool hasBreeds = false,
  }) async {
    _isLoadingImages = true;
    _error = null;
    notifyListeners();

    try {
      _catImages = await _theCatApiService.getRandomImages(
        limit: limit,
        hasBreeds: hasBreeds,
      );
      if (_catImages.isNotEmpty) {
        _currentImage = _catImages.first;
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load cat images';
    } finally {
      _isLoadingImages = false;
      notifyListeners();
    }
  }

  /// Load images for a specific breed
  Future<void> loadBreedImages(String breedId, {int limit = 10}) async {
    _isLoadingImages = true;
    _error = null;
    notifyListeners();

    try {
      _catImages = await _theCatApiService.getBreedImages(breedId, limit: limit);
      if (_catImages.isNotEmpty) {
        _currentImage = _catImages.first;
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load breed images';
    } finally {
      _isLoadingImages = false;
      notifyListeners();
    }
  }

  /// Get a new random image
  Future<void> refreshImage({bool hasBreeds = false}) async {
    _isLoadingImages = true;
    _error = null;
    notifyListeners();

    try {
      _currentImage = await _theCatApiService.getRandomImage(
        hasBreeds: hasBreeds,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load cat image';
    } finally {
      _isLoadingImages = false;
      notifyListeners();
    }
  }

  // ============================================
  // CATAAS (Cat as a Service)
  // ============================================

  /// Load available CATAAS tags
  Future<void> loadCataasTags() async {
    if (_cataaTags.isNotEmpty) return;

    try {
      _cataaTags = await _cataasService.getTags();
      notifyListeners();
    } catch (e) {
      // Tags are optional, don't show error
      debugPrint('Failed to load CATAAS tags: $e');
    }
  }

  /// Get URL for a random cat image from CATAAS
  String getRandomCatImageUrl({
    String? tag,
    String? text,
    int? fontSize,
    String? fontColor,
  }) {
    return _cataasService.getRandomCatUrl(
      tag: tag,
      text: text,
      fontSize: fontSize,
      fontColor: fontColor,
    );
  }

  /// Get URL for a random GIF cat
  String getRandomGifUrl() => _cataasService.getRandomGifUrl();

  /// Get URL for a cat saying text
  String getCatSaysUrl(String text, {String? fontColor}) {
    return _cataasService.getCatSaysUrl(text, fontColor: fontColor);
  }

  // ============================================
  // HTTP CATS
  // ============================================

  /// Get HTTP cat for a status code
  HttpCatImage getHttpCat(int statusCode) {
    return _httpCatService.getStatusCat(statusCode);
  }

  /// Get URL for HTTP status cat
  String getHttpCatUrl(int statusCode) {
    return _httpCatService.getStatusCatUrl(statusCode);
  }

  /// Get all available HTTP cat status codes
  List<int> getAllHttpStatusCodes() {
    return _httpCatService.getAllStatusCodes();
  }

  /// Get popular HTTP status codes
  List<int> getPopularHttpStatusCodes() {
    return _httpCatService.getPopularStatusCodes();
  }

  /// Get random HTTP cat
  HttpCatImage getRandomHttpCat() {
    return _httpCatService.getRandomCat();
  }

  /// Search HTTP cats by status code or text
  List<HttpCatImage> searchHttpCats(String query) {
    return _httpCatService.searchStatusCodes(query);
  }

  // ============================================
  // UTILITY
  // ============================================

  /// Clear all errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all cached data
  void clearCache() {
    _facts = [];
    _breeds = [];
    _catImages = [];
    _cataaTags = [];
    _currentFact = null;
    _currentImage = null;
    _selectedBreed = null;
    _error = null;
    notifyListeners();
  }
}
