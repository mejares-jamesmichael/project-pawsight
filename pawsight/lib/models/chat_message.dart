/// Model representing a chat message in the AI conversation
/// 
/// Supports both user messages and AI responses with SQLite persistence
class ChatMessage {
  final int? id;
  final String odId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    this.id,
    required this.odId,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  /// Create from SQLite map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      odId: map['user_id'] as String,
      content: map['content'] as String,
      isUser: (map['is_user'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isError: (map['is_error'] as int?) == 1,
    );
  }

  /// Convert to SQLite map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': odId,
      'content': content,
      'is_user': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'is_error': isError ? 1 : 0,
    };
  }

  /// Create a user message
  factory ChatMessage.user({
    required String odId,
    required String content,
  }) {
    return ChatMessage(
      odId: odId,
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  /// Create an AI response message
  factory ChatMessage.ai({
    required String odId,
    required String content,
    bool isError = false,
  }) {
    return ChatMessage(
      odId: odId,
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      isError: isError,
    );
  }

  /// Create a copy with updated fields
  ChatMessage copyWith({
    int? id,
    String? odId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      odId: odId ?? this.odId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, isUser: $isUser, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}
