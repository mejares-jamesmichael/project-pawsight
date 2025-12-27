# Provider State Management Guide

## Core Concepts

Provider is a wrapper around InheritedWidget that makes state management simple and efficient.

## Provider Types

- **ChangeNotifierProvider**: For mutable state (ViewModels)
- **Provider**: For immutable dependencies
- **FutureProvider**: For async initialization
- **StreamProvider**: For stream-based data

## PawSight Pattern

We use **ChangeNotifierProvider** exclusively for ViewModels.

## ViewModel Structure

```dart
class MyProvider extends ChangeNotifier {
  // 1. Private state fields
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;
  
  // 2. Public getters (immutable access)
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 3. Public methods (mutations)
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();  // Notify before async
    
    try {
      _items = await _fetchItems();
      _isLoading = false;
      notifyListeners();  // Notify on success
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();  // Notify on error
    }
  }
  
  // 4. Cleanup
  @override
  void dispose() {
    // Clean up resources (streams, controllers, etc.)
    super.dispose();
  }
}
```

## Accessing State in Widgets

### context.watch - Listen to changes

```dart
@override
Widget build(BuildContext context) {
  final provider = context.watch<MyProvider>();
  return Text(provider.data);  // Rebuilds when data changes
}
```

### context.read - One-time access (actions)

```dart
ElevatedButton(
  onPressed: () {
    context.read<MyProvider>().doSomething();
  },
  child: const Text('Action'),
)
```

### Consumer - Granular rebuilds

```dart
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return Text(provider.data);
  },
)
```

### Selector - Rebuild on specific changes

```dart
Selector<MyProvider, String>(
  selector: (context, provider) => provider.specificValue,
  builder: (context, value, child) {
    return Text(value);  // Only rebuilds when specificValue changes
  },
)
```

## Best Practices

### 1. Always call notifyListeners()

```dart
// ❌ Bad
void updateValue(String newValue) {
  _value = newValue;  // UI won't update!
}

// ✅ Good
void updateValue(String newValue) {
  _value = newValue;
  notifyListeners();
}
```

### 2. Private fields, public getters

```dart
// ❌ Bad - external code can modify without notification
List<Item> items = [];

// ✅ Good - controlled access
List<Item> _items = [];
List<Item> get items => _items;
```

### 3. Handle loading and error states

```dart
class MyProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Fetch data
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 4. Use context.read for actions

```dart
// ❌ Bad - in build method
@override
Widget build(BuildContext context) {
  final provider = context.watch<MyProvider>();
  
  return ElevatedButton(
    onPressed: () => provider.doSomething(),  // Listening unnecessarily
    child: const Text('Action'),
  );
}

// ✅ Good
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      context.read<MyProvider>().doSomething();  // No listening
    },
    child: const Text('Action'),
  );
}
```

### 5. Filter Pattern (used in LibraryProvider)

```dart
void setMoodFilter(String? mood) {
  // Toggle: if same mood clicked, clear filter
  _selectedMood = mood == _selectedMood ? null : mood;
  _applyFilters();
  notifyListeners();
}

void _applyFilters() {
  _filteredItems = _allItems.where((item) {
    final matchesMood = _selectedMood == null || item.mood == _selectedMood;
    final matchesSearch = _searchQuery.isEmpty || 
        item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchesMood && matchesSearch;
  }).toList();
}
```

## Common Mistakes

### Mistake 1: Using context.read in build

```dart
// ❌ Wrong - won't rebuild on changes
@override
Widget build(BuildContext context) {
  final provider = context.read<MyProvider>();
  return Text(provider.value);
}

// ✅ Correct
@override
Widget build(BuildContext context) {
  final provider = context.watch<MyProvider>();
  return Text(provider.value);
}
```

### Mistake 2: Forgetting notifyListeners

```dart
// ❌ Wrong - UI won't update
void toggle() {
  _isEnabled = !_isEnabled;
}

// ✅ Correct
void toggle() {
  _isEnabled = !_isEnabled;
  notifyListeners();
}
```

### Mistake 3: Calling notifyListeners in getter

```dart
// ❌ Wrong - infinite loop!
bool get isEnabled {
  notifyListeners();
  return _isEnabled;
}

// ✅ Correct - only in setters/methods
void setEnabled(bool value) {
  _isEnabled = value;
  notifyListeners();
}
```

## Testing Providers

```dart
test('loadItems updates state correctly', () async {
  // Arrange
  final provider = MyProvider();
  
  // Act
  await provider.loadItems();
  
  // Assert
  expect(provider.isLoading, false);
  expect(provider.items, isNotEmpty);
  expect(provider.error, null);
});

test('error is set when fetch fails', () async {
  final provider = MyProvider(mockFailingService);
  
  await provider.loadItems();
  
  expect(provider.error, isNotNull);
  expect(provider.items, isEmpty);
});
```

## Registration in main.dart

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => HotlineProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

## Summary

1. **Extend ChangeNotifier** for ViewModels
2. **Private state + public getters**
3. **Always call notifyListeners()** after state changes
4. **Use context.watch** in build methods
5. **Use context.read** for actions
6. **Handle loading and error states**
7. **Test Providers independently**
