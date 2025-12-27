# Provider Template

Use this template when creating new Providers (ViewModels) in PawSight.

## Basic Provider

```dart
import 'package:flutter/foundation.dart';
import '../services/{service_name}.dart';
import '../models/{model_name}.dart';

class {FeatureName}Provider extends ChangeNotifier {
  // Dependencies
  final {ServiceName} _service = {ServiceName}();

  // Private state fields
  List<{ModelName}> _items = [];
  bool _isLoading = false;
  String? _error;

  // Public getters (immutable access)
  List<{ModelName}> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Public methods (state mutations)
  
  /// Loads items from the service.
  /// Sets loading state during fetch and error state on failure.
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _service.fetchItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    // Dispose controllers, streams, etc.
    super.dispose();
  }
}
```

## Provider with Search and Filters

```dart
import 'package:flutter/foundation.dart';
import '../services/{service_name}.dart';
import '../models/{model_name}.dart';

class {FeatureName}Provider extends ChangeNotifier {
  final {ServiceName} _service = {ServiceName}();

  // State
  List<{ModelName}> _allItems = [];
  List<{ModelName}> _filteredItems = [];
  String _searchQuery = '';
  String? _selectedFilter;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<{ModelName}> get items => _filteredItems;
  String get searchQuery => _searchQuery;
  String? get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load data
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await _service.fetchItems();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter (toggle pattern)
  void setFilter(String? filter) {
    // Toggle: if same filter clicked, clear it
    _selectedFilter = _selectedFilter == filter ? null : filter;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredItems = _allItems.where((item) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Category filter
      final matchesFilter = _selectedFilter == null ||
          item.category == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
```

## Provider with Form State

```dart
import 'package:flutter/foundation.dart';
import '../services/{service_name}.dart';
import '../models/{model_name}.dart';

class {FeatureName}Provider extends ChangeNotifier {
  final {ServiceName} _service = {ServiceName}();

  // Form state
  String _field1 = '';
  String _field2 = '';
  bool _isSubmitting = false;
  String? _error;
  String? _successMessage;

  // Getters
  String get field1 => _field1;
  String get field2 => _field2;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isValid => _field1.isNotEmpty && _field2.isNotEmpty;

  // Setters
  void setField1(String value) {
    _field1 = value;
    _error = null;  // Clear error on input
    notifyListeners();
  }

  void setField2(String value) {
    _field2 = value;
    _error = null;
    notifyListeners();
  }

  // Submit
  Future<void> submit() async {
    if (!isValid) {
      _error = 'Please fill all fields';
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _service.submit(_field1, _field2);
      _successMessage = 'Submitted successfully';
      _clearForm();
      _isSubmitting = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _clearForm() {
    _field1 = '';
    _field2 = '';
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
```

## Key Patterns

### Loading Pattern

```dart
Future<void> operation() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // Do work
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}
```

### Toggle Pattern

```dart
void toggleValue(String? value) {
  _value = _value == value ? null : value;
  notifyListeners();
}
```

### Validation Pattern

```dart
void validateAndSubmit() {
  if (!_isValid()) {
    _error = 'Validation failed';
    notifyListeners();
    return;
  }
  
  _submit();
}
```

## Rules

1. **Extend ChangeNotifier**
2. **Private state** (`_field`), **public getters**
3. **Always call notifyListeners()** after state changes
4. **Handle loading and error states**
5. **Use try/catch** for async operations
6. **Dispose resources** in dispose()
7. **No BuildContext** in Provider
8. **No UI code** in Provider

## Registration

```dart
// In lib/main.dart
ChangeNotifierProvider(create: (_) => {FeatureName}Provider()),
```

## Testing

```dart
test('loadItems updates state correctly', () async {
  final provider = {FeatureName}Provider();
  
  await provider.loadItems();
  
  expect(provider.isLoading, false);
  expect(provider.items, isNotEmpty);
  expect(provider.error, null);
});
```
