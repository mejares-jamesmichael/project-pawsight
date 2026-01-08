import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service for managing anonymous user sessions (Lazy Authentication)
/// 
/// Generates a unique UUID on first launch and persists it across app restarts.
/// This allows the backend to identify users without requiring email/password.
class UserSessionService {
  static const String _userIdKey = 'pawsight_user_id';
  static final UserSessionService _instance = UserSessionService._internal();
  
  String? _userId;
  
  factory UserSessionService() => _instance;
  
  UserSessionService._internal();
  
  /// Get the current user ID (generates one if doesn't exist)
  String get userId {
    if (_userId == null) {
      throw StateError('UserSessionService not initialized. Call initialize() first.');
    }
    return _userId!;
  }
  
  /// Check if session is initialized
  bool get isInitialized => _userId != null;
  
  /// Initialize the user session
  /// 
  /// Should be called once during app startup (in main.dart)
  /// Retrieves existing UUID or generates a new one
  Future<void> initialize() async {
    if (_userId != null) return; // Already initialized
    
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_userIdKey);
    
    if (_userId == null) {
      // First launch - generate new UUID
      _userId = const Uuid().v4();
      await prefs.setString(_userIdKey, _userId!);
    }
  }
  
  /// Clear the user session (for testing or reset purposes)
  /// 
  /// WARNING: This will generate a new user ID on next initialize()
  /// The user will lose their conversation history on the server
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    _userId = null;
  }
  
  /// Get user ID for display (shortened version)
  /// 
  /// Returns first 8 characters of UUID for UI display
  String get shortUserId {
    if (_userId == null) return 'Unknown';
    return _userId!.substring(0, 8);
  }
}
