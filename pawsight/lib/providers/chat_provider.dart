import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/chat_api_service.dart';
import '../services/connectivity_service.dart';
import '../services/database_helper.dart';
import '../services/user_session_service.dart';

/// Provider for managing chat state and AI communication
///
/// Handles message sending, rate limiting, error states, and persistence.
class ChatProvider extends ChangeNotifier {
  final DatabaseHelper _database = DatabaseHelper.instance;
  final ChatApiService _api = ChatApiService();
  final UserSessionService _userSession = UserSessionService();
  final ConnectivityService _connectivity = ConnectivityService();

  // Timer for refreshing rate limit UI
  Timer? _rateLimitTimer;

  // Message storage
  final List<ChatMessage> _messages = [];
  UnmodifiableListView<ChatMessage> get messages =>
      UnmodifiableListView(_messages);

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;
  bool get hasError => _error != null;

  // Rate limiting: 5 requests per minute
  static const int _maxRequestsPerMinute = 5;
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const Duration _cooldownDuration = Duration(seconds: 30);

  final List<DateTime> _requestTimestamps = [];
  DateTime? _cooldownUntil;

  bool get isOnCooldown =>
      _cooldownUntil != null && DateTime.now().isBefore(_cooldownUntil!);

  int get remainingRequests {
    _cleanupOldTimestamps();
    return (_maxRequestsPerMinute - _requestTimestamps.length)
        .clamp(0, _maxRequestsPerMinute);
  }

  Duration? get cooldownRemaining {
    if (_cooldownUntil == null) return null;
    final remaining = _cooldownUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  // Convenience getters
  bool get isOffline => _connectivity.isOffline;
  bool get canSendMessage =>
      !_isLoading && !isOnCooldown && !isOffline && remainingRequests > 0;

  /// Initialize the provider and load chat history
  Future<void> initialize() async {
    await loadHistory();
  }

  /// Load chat history from SQLite
  Future<void> loadHistory() async {
    try {
      final userId = _userSession.userId;
      final dbMessages = await _database.getChatMessages(userId);
      _messages.clear();
      _messages.addAll(dbMessages);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load chat history: $e');
      _error = 'Failed to load chat history';
      notifyListeners();
    }
  }

  /// Send a message to the AI
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Check if offline
    if (isOffline) {
      _error = 'You are offline. Please check your connection.';
      notifyListeners();
      return;
    }

    // Check rate limit
    if (!_checkRateLimit()) {
      _startCooldown();
      _error = 'Too many messages. Please wait ${_cooldownDuration.inSeconds} seconds.';
      notifyListeners();
      return;
    }

    final userId = _userSession.userId;
    final trimmedContent = content.trim();

    // Create and save user message
    final userMessage = ChatMessage.user(
      odId: userId,
      content: trimmedContent,
    );

    _messages.add(userMessage);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Save user message to database
      final savedUserMessage = await _database.insertChatMessage(userMessage);
      final userIndex = _messages.length - 1;
      if (userIndex >= 0) {
        _messages[userIndex] = savedUserMessage;
      }

      // Get conversation context (last 5 messages before current)
      final context = await _database.getLastChatMessages(userId, limit: 5);

      // Send to API
      _recordRequest();
      final response = await _api.sendMessage(
        userId: userId,
        message: trimmedContent,
        context: context,
      );

      // Create and save AI response
      final aiMessage = ChatMessage.ai(
        odId: userId,
        content: response,
      );

      final savedAiMessage = await _database.insertChatMessage(aiMessage);
      _messages.add(savedAiMessage);

      _isLoading = false;
      notifyListeners();
    } on ChatApiException catch (e) {
      await _handleError(userId, e.message);
    } catch (e) {
      await _handleError(userId, 'An unexpected error occurred. Please try again.');
    }
  }

  /// Handle errors by creating an error message
  Future<void> _handleError(String userId, String errorMessage) async {
    final errorMsg = ChatMessage.ai(
      odId: userId,
      content: errorMessage,
      isError: true,
    );

    final savedErrorMessage = await _database.insertChatMessage(errorMsg);
    _messages.add(savedErrorMessage);

    _isLoading = false;
    _error = errorMessage;
    notifyListeners();
  }

  /// Retry the last failed message
  Future<void> retryLastMessage() async {
    // Find the last user message before the error
    for (int i = _messages.length - 1; i >= 0; i--) {
      final msg = _messages[i];
      if (msg.isUser) {
        // Remove error messages after this user message
        while (_messages.length > i + 1) {
          final lastMsg = _messages.last;
          if (lastMsg.id != null) {
            await _database.deleteChatMessage(lastMsg.id!);
          }
          _messages.removeLast();
        }

        // Resend the message
        _error = null;
        notifyListeners();
        await _resendMessage(msg.content);
        return;
      }
    }
  }

  /// Resend a message (internal use for retry)
  Future<void> _resendMessage(String content) async {
    if (isOffline) {
      _error = 'You are offline. Please check your connection.';
      notifyListeners();
      return;
    }

    final userId = _userSession.userId;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get conversation context
      final context = await _database.getLastChatMessages(userId, limit: 5);

      // Send to API
      _recordRequest();
      final response = await _api.sendMessage(
        userId: userId,
        message: content,
        context: context,
      );

      // Create and save AI response
      final aiMessage = ChatMessage.ai(
        odId: userId,
        content: response,
      );

      final savedAiMessage = await _database.insertChatMessage(aiMessage);
      _messages.add(savedAiMessage);

      _isLoading = false;
      notifyListeners();
    } on ChatApiException catch (e) {
      await _handleError(userId, e.message);
    } catch (e) {
      await _handleError(userId, 'An unexpected error occurred. Please try again.');
    }
  }

  /// Clear all chat history
  Future<void> clearHistory() async {
    try {
      final userId = _userSession.userId;
      await _database.clearChatHistory(userId);
      _messages.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear chat history';
      notifyListeners();
    }
  }

  /// Clear the current error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Rate limiting helpers

  /// Check if we're within rate limit
  bool _checkRateLimit() {
    if (isOnCooldown) return false;
    _cleanupOldTimestamps();
    return _requestTimestamps.length < _maxRequestsPerMinute;
  }

  /// Record a request timestamp
  void _recordRequest() {
    _requestTimestamps.add(DateTime.now());
    _startRateLimitTimer();
    notifyListeners();
  }

  /// Start timer to refresh rate limit UI every 10 seconds
  void _startRateLimitTimer() {
    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final oldCount = _requestTimestamps.length;
      _cleanupOldTimestamps();
      // Only notify if timestamps were cleaned up
      if (_requestTimestamps.length != oldCount || _requestTimestamps.isEmpty) {
        notifyListeners();
      }
      // Stop timer when all requests have expired
      if (_requestTimestamps.isEmpty) {
        _rateLimitTimer?.cancel();
        _rateLimitTimer = null;
      }
    });
  }

  /// Remove timestamps older than the rate limit window
  void _cleanupOldTimestamps() {
    final cutoff = DateTime.now().subtract(_rateLimitWindow);
    _requestTimestamps.removeWhere((t) => t.isBefore(cutoff));
  }

  /// Start cooldown period after hitting rate limit
  void _startCooldown() {
    _cooldownUntil = DateTime.now().add(_cooldownDuration);

    // Schedule cooldown end notification
    Future.delayed(_cooldownDuration, () {
      _cooldownUntil = null;
      _error = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _rateLimitTimer?.cancel();
    _messages.clear();
    super.dispose();
  }
}
