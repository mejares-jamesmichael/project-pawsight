import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Base API service with common HTTP functionality, error handling,
/// and retry logic with exponential backoff.
///
/// All cat-related API services should extend this class.
abstract class BaseApiService {
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 15);
  static const Duration _baseRetryDelay = Duration(seconds: 1);

  /// Override in subclasses to provide base URL
  String get baseUrl;

  /// Override in subclasses for service-specific headers
  Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
      };

  /// Make a GET request with retry logic
  ///
  /// [endpoint] - API endpoint (will be appended to baseUrl)
  /// [queryParams] - Optional query parameters
  /// [headers] - Optional additional headers
  ///
  /// Returns parsed JSON response
  /// Throws [ApiException] on failure
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    return _executeWithRetry(() => _makeGetRequest(uri, headers));
  }

  /// Make a GET request that returns raw bytes (for images)
  ///
  /// [endpoint] - API endpoint (will be appended to baseUrl)
  /// [queryParams] - Optional query parameters
  ///
  /// Returns raw response bytes
  /// Throws [ApiException] on failure
  Future<List<int>> getBytes(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    return _executeWithRetry(() => _makeGetBytesRequest(uri));
  }

  /// Build the full URI from endpoint and query parameters
  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final url = endpoint.startsWith('http') ? endpoint : '$baseUrl$endpoint';
    final uri = Uri.parse(url);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams,
      });
    }

    return uri;
  }

  /// Execute request with retry logic and exponential backoff
  Future<T> _executeWithRetry<T>(Future<T> Function() request) async {
    Exception? lastException;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await request();
      } on ApiException catch (e) {
        // Don't retry on client errors (4xx)
        if (!e.isRetryable) {
          rethrow;
        }
        lastException = e;
      } on SocketException catch (e) {
        lastException = ApiException(
          'Network error. Please check your connection.',
          isRetryable: true,
          originalError: e,
        );
      } on TimeoutException catch (e) {
        lastException = ApiException(
          'Request timed out. Please try again.',
          isRetryable: true,
          originalError: e,
        );
      } catch (e) {
        lastException = ApiException(
          'An unexpected error occurred.',
          isRetryable: true,
          originalError: e,
        );
      }

      // Wait before retrying (exponential backoff: 1s, 2s, 4s)
      if (attempt < _maxRetries - 1) {
        final delay = _baseRetryDelay * (1 << attempt);
        await Future.delayed(delay);
      }
    }

    throw lastException ??
        ApiException('Failed after $_maxRetries attempts.');
  }

  /// Make the actual GET request
  Future<dynamic> _makeGetRequest(
    Uri uri,
    Map<String, String>? additionalHeaders,
  ) async {
    final headers = {...defaultHeaders};
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    final response = await http.get(uri, headers: headers).timeout(_timeout);

    return _handleResponse(response);
  }

  /// Make a GET request that returns raw bytes
  Future<List<int>> _makeGetBytesRequest(Uri uri) async {
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }

    throw _createExceptionFromStatus(response.statusCode);
  }

  /// Handle HTTP response and parse JSON
  dynamic _handleResponse(http.Response response) {
    // Handle HTTP status codes
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      try {
        return jsonDecode(response.body);
      } on FormatException catch (e) {
        throw ApiException(
          'Failed to parse server response.',
          isRetryable: false,
          originalError: e,
        );
      }
    }

    throw _createExceptionFromStatus(response.statusCode);
  }

  /// Create appropriate exception based on HTTP status code
  ApiException _createExceptionFromStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return ApiException(
          'Bad request. Please try again.',
          statusCode: 400,
          isRetryable: false,
        );
      case 401:
      case 403:
        return ApiException(
          'Authentication failed.',
          statusCode: statusCode,
          isRetryable: false,
        );
      case 404:
        return ApiException(
          'Resource not found.',
          statusCode: 404,
          isRetryable: false,
        );
      case 429:
        return ApiException(
          'Too many requests. Please wait and try again.',
          statusCode: 429,
          isRetryable: false,
        );
      case >= 500:
        return ApiException(
          'Server error. Please try again later.',
          statusCode: statusCode,
          isRetryable: true,
        );
      default:
        return ApiException(
          'Request failed with status $statusCode.',
          statusCode: statusCode,
          isRetryable: statusCode >= 500,
        );
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final bool isRetryable;
  final int? statusCode;
  final Object? originalError;

  ApiException(
    this.message, {
    this.isRetryable = false,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ApiException: $message';
}
