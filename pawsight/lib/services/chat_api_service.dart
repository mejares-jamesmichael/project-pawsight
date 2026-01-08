import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

/// Service for communicating with the n8n AI chat webhook
///
/// Handles HTTP requests, retry logic with exponential backoff,
/// and error handling for the AI chat feature.
class ChatApiService {
  static const String _webhookUrl =
      'https://automate.kaelvxdev.space/webhook/289fbf89-704a-4b0a-8bf7-9fe027709f7e';

  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _baseRetryDelay = Duration(seconds: 1);

  static final ChatApiService _instance = ChatApiService._internal();

  factory ChatApiService() => _instance;

  ChatApiService._internal();

  /// Send a message to the AI and get a response
  ///
  /// [userId] - The user's unique identifier for session tracking
  /// [message] - The user's message to send
  /// [context] - Optional list of previous messages for conversation context
  ///
  /// Returns the AI's response text
  /// Throws [ChatApiException] on failure
  Future<String> sendMessage({
    required String userId,
    required String message,
    List<ChatMessage>? context,
  }) async {
    final requestBody = _buildRequestBody(userId, message, context);

    Exception? lastException;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await _makeRequest(requestBody);
        return _parseResponse(response);
      } on ChatApiException catch (e) {
        // Don't retry on client errors (4xx) or rate limits
        if (!e.isRetryable) {
          rethrow;
        }
        lastException = e;
      } on SocketException catch (e) {
        lastException = ChatApiException(
          'Network error. Please check your connection.',
          isRetryable: true,
          originalError: e,
        );
      } on TimeoutException catch (e) {
        lastException = ChatApiException(
          'Request timed out. Please try again.',
          isRetryable: true,
          originalError: e,
        );
      } catch (e) {
        lastException = ChatApiException(
          'An unexpected error occurred.',
          isRetryable: true,
          originalError: e,
        );
      }

      // Wait before retrying (exponential backoff)
      if (attempt < _maxRetries - 1) {
        final delay = _baseRetryDelay * (1 << attempt); // 1s, 2s, 4s
        await Future.delayed(delay);
      }
    }

    // All retries exhausted
    throw lastException ??
        ChatApiException('Failed to get response after $_maxRetries attempts.');
  }

  /// Build the JSON request body
  Map<String, dynamic> _buildRequestBody(
    String userId,
    String message,
    List<ChatMessage>? context,
  ) {
    final body = <String, dynamic>{
      'userId': userId,
      'message': message,
    };

    if (context != null && context.isNotEmpty) {
      body['context'] = context.map((msg) {
        return {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        };
      }).toList();
    }

    return body;
  }

  /// Make the HTTP POST request
  Future<http.Response> _makeRequest(Map<String, dynamic> body) async {
    final response = await http
        .post(
          Uri.parse(_webhookUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    return response;
  }

  /// Parse the response and extract the AI message
  String _parseResponse(http.Response response) {
    // Handle HTTP status codes
    if (response.statusCode == 429) {
      throw ChatApiException(
        'Too many requests. Please wait a moment and try again.',
        isRetryable: false,
        statusCode: 429,
      );
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw ChatApiException(
        'Authentication failed. Please restart the app.',
        isRetryable: false,
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 500) {
      throw ChatApiException(
        'Server error. Please try again later.',
        isRetryable: true,
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode != 200) {
      throw ChatApiException(
        'Request failed with status ${response.statusCode}.',
        isRetryable: response.statusCode >= 500,
        statusCode: response.statusCode,
      );
    }

    // Parse JSON response
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Check for error in response body
      if (json.containsKey('error')) {
        final error = json['error'] as String;
        throw ChatApiException(
          error,
          isRetryable: false,
        );
      }

      // Extract the AI response - check common keys used by different AI services
      // n8n AI Agent uses 'output', others might use 'response', 'message', or 'text'
      if (json.containsKey('output')) {
        final aiResponse = json['output'];
        if (aiResponse is String && aiResponse.isNotEmpty) {
          return aiResponse;
        }
      }

      if (json.containsKey('response')) {
        final aiResponse = json['response'];
        if (aiResponse is String && aiResponse.isNotEmpty) {
          return aiResponse;
        }
      }

      // Fallback: check for 'message' or 'text' keys
      if (json.containsKey('message')) {
        return json['message'] as String;
      }
      if (json.containsKey('text')) {
        return json['text'] as String;
      }

      throw ChatApiException(
        'Invalid response format from server.',
        isRetryable: false,
      );
    } on FormatException catch (e) {
      throw ChatApiException(
        'Failed to parse server response.',
        isRetryable: false,
        originalError: e,
      );
    }
  }
}

/// Custom exception for Chat API errors
class ChatApiException implements Exception {
  final String message;
  final bool isRetryable;
  final int? statusCode;
  final Object? originalError;

  ChatApiException(
    this.message, {
    this.isRetryable = false,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ChatApiException: $message';
}
