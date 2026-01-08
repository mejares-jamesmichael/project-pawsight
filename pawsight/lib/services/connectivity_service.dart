import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring network connectivity status
/// 
/// Provides real-time network status updates and checks for offline handling
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  bool _isConnected = true;
  bool _isInitialized = false;
  
  factory ConnectivityService() => _instance;
  
  ConnectivityService._internal();
  
  /// Whether the device is currently connected to the internet
  bool get isConnected => _isConnected;
  
  /// Whether the device is offline
  bool get isOffline => !_isConnected;
  
  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;
  
  /// Initialize the connectivity service
  /// 
  /// Should be called once during app startup
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Check initial connectivity status
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
    
    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    
    _isInitialized = true;
  }
  
  /// Update connection status based on connectivity results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    
    // Check if any result indicates connectivity
    _isConnected = results.any((result) => 
      result != ConnectivityResult.none
    );
    
    // Only notify if status actually changed
    if (wasConnected != _isConnected) {
      notifyListeners();
    }
  }
  
  /// Check current connectivity status (one-time check)
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
    return _isConnected;
  }
  
  /// Dispose of the subscription
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
