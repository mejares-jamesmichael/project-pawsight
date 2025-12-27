# Error Handling Standards

Consistent error handling patterns for PawSight.

## General Principles

1. **Always use try/catch** around async operations
2. **User-friendly messages** - No technical jargon
3. **Store errors in state** - Provider manages error state
4. **Display errors in UI** - Give user feedback
5. **Provide recovery** - Offer retry or alternative action

## Error Types

### Network Errors

**Scenario**: No internet connection, network timeout

**Handling**:
```dart
if (error is SocketException) {
  return 'No internet connection. Please check your network.';
} else if (error.toString().contains('TimeoutException')) {
  return 'Request timed out. Please try again later.';
}
```

### HTTP Errors

**Scenario**: 4xx, 5xx status codes

**Handling**:
```dart
if (response.statusCode == 404) {
  throw Exception('Resource not found');
} else if (response.statusCode >= 500) {
  throw Exception('Server error. Please try again later.');
} else if (response.statusCode >= 400) {
  throw Exception('Bad request. Please check your input.');
}
```

### Parse Errors

**Scenario**: Invalid JSON, unexpected response format

**Handling**:
```dart
try {
  final data = json.decode(response.body);
  return MyModel.fromJson(data);
} catch (e) {
  throw Exception('Invalid response from server');
}
```

### Database Errors

**Scenario**: SQLite errors, constraint violations

**Handling**:
```dart
try {
  await db.insert('table', data);
} catch (e) {
  throw Exception('Failed to save data');
}
```

## Provider Error Pattern

```dart
class MyProvider extends ChangeNotifier {
  String? _error;
  bool _isLoading = false;
  
  String? get error => _error;
  bool get isLoading => _isLoading;
  
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;  // Clear previous error
    notifyListeners();
    
    try {
      final data = await _service.fetch();
      _processData(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out';
    } else {
      return 'An unexpected error occurred';
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

## UI Error Display

```dart
Consumer<MyProvider>(
  builder: (context, provider, child) {
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.fetchData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // ... normal UI
  },
)
```

## Timeout Configuration

```dart
class ApiService {
  static const Duration _shortTimeout = Duration(seconds: 10);
  static const Duration _longTimeout = Duration(seconds: 30);
  
  Future<Response> get(String url) async {
    return await http
        .get(Uri.parse(url))
        .timeout(_shortTimeout);
  }
  
  Future<Response> postWithFile(String url, File file) async {
    // Longer timeout for uploads
    return await request.send()
        .timeout(_longTimeout);
  }
}
```

## Offline Fallback

```dart
Future<List<Item>> fetchItems() async {
  try {
    // Try network first
    return await _apiService.fetchItems();
  } catch (e) {
    if (e is SocketException) {
      // Fallback to cache
      final cached = await _cacheService.getCachedItems();
      if (cached.isNotEmpty) {
        return cached;
      }
    }
    rethrow;  // Re-throw if not network error or no cache
  }
}
```

## Validation Errors

```dart
void validateInput(String input) {
  if (input.isEmpty) {
    _error = 'Please enter a value';
    notifyListeners();
    return;
  }
  
  if (input.length < 3) {
    _error = 'Must be at least 3 characters';
    notifyListeners();
    return;
  }
  
  _error = null;
  // Process valid input
}
```

## Logging Errors

```dart
Future<void> fetchData() async {
  try {
    final data = await _service.fetch();
    _processData(data);
  } catch (e, stackTrace) {
    // Log technical details for debugging
    print('Error fetching data: $e');
    print('Stack trace: $stackTrace');
    
    // Show user-friendly message
    _error = _getErrorMessage(e);
    notifyListeners();
  }
}
```

## Error Recovery Actions

```dart
// Retry action
ElevatedButton(
  onPressed: () => provider.retry(),
  child: const Text('Retry'),
)

// Alternative action
TextButton(
  onPressed: () => provider.loadFromCache(),
  child: const Text('Use Cached Data'),
)

// Dismiss action
TextButton(
  onPressed: () {
    provider.clearError();
    Navigator.pop(context);
  },
  child: const Text('Go Back'),
)
```

## User-Friendly Error Messages

```dart
Map<String, String> errorMessages = {
  'network': 'No internet connection. Please check your network and try again.',
  'timeout': 'Request timed out. The server might be slow or unreachable.',
  'not_found': 'The requested resource was not found.',
  'server': 'Server error. Please try again later.',
  'parse': 'Received invalid data from server. Please contact support.',
  'unknown': 'An unexpected error occurred. Please try again.',
};
```

## Checklist

For every async operation:
- [ ] Wrapped in try/catch
- [ ] Error stored in Provider state
- [ ] User-friendly error message
- [ ] Error displayed in UI
- [ ] Retry or recovery action provided
- [ ] Technical details logged (not shown to user)
- [ ] Loading state handled
- [ ] Timeout configured
