import '../models/http_cat_image.dart';

/// Service for HTTP Cats - cat images for HTTP status codes
///
/// API: https://http.cat
/// A simple, fun API that returns cat images for any HTTP status code
class HttpCatService {
  static const String _baseUrl = 'https://http.cat';

  static final HttpCatService _instance = HttpCatService._internal();

  factory HttpCatService() => _instance;

  HttpCatService._internal();

  /// Get HTTP cat image info for a status code
  ///
  /// [statusCode] - HTTP status code (e.g., 200, 404, 500)
  HttpCatImage getStatusCat(int statusCode) {
    return HttpCatImage.fromStatusCode(statusCode);
  }

  /// Get image URL for a status code
  String getStatusCatUrl(int statusCode) {
    return '$_baseUrl/$statusCode';
  }

  /// Get image URL with .jpg extension
  String getStatusCatUrlWithExtension(int statusCode) {
    return '$_baseUrl/$statusCode.jpg';
  }

  /// Get all available status codes
  List<int> getAllStatusCodes() {
    return HttpCatImage.availableStatusCodes;
  }

  /// Get popular/common status codes
  List<int> getPopularStatusCodes() {
    return HttpCatImage.popularStatusCodes;
  }

  /// Get status codes by category
  List<HttpCatImage> getStatusCodesByCategory(String category) {
    return HttpCatImage.availableStatusCodes
        .map((code) => HttpCatImage.fromStatusCode(code))
        .where((cat) => cat.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get all informational status codes (1xx)
  List<HttpCatImage> getInformationalCodes() =>
      getStatusCodesByCategory('Informational');

  /// Get all success status codes (2xx)
  List<HttpCatImage> getSuccessCodes() => getStatusCodesByCategory('Success');

  /// Get all redirection status codes (3xx)
  List<HttpCatImage> getRedirectionCodes() =>
      getStatusCodesByCategory('Redirection');

  /// Get all client error status codes (4xx)
  List<HttpCatImage> getClientErrorCodes() =>
      getStatusCodesByCategory('Client Error');

  /// Get all server error status codes (5xx)
  List<HttpCatImage> getServerErrorCodes() =>
      getStatusCodesByCategory('Server Error');

  /// Get a random HTTP cat
  HttpCatImage getRandomCat() {
    final codes = HttpCatImage.availableStatusCodes;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % codes.length;
    return HttpCatImage.fromStatusCode(codes[randomIndex]);
  }

  /// Search status codes by text
  List<HttpCatImage> searchStatusCodes(String query) {
    final lowerQuery = query.toLowerCase();
    return HttpCatImage.availableStatusCodes
        .map((code) => HttpCatImage.fromStatusCode(code))
        .where((cat) =>
            cat.statusCode.toString().contains(query) ||
            cat.statusText.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
