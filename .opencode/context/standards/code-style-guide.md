# Code Style Guide

Based on AGENTS.md and Flutter best practices for PawSight.

## File Organization

```
pawsight/lib/
├── models/           # Data classes
├── services/         # Database/API access
├── providers/        # ViewModels (ChangeNotifier)
├── screens/          # Screen widgets
├── widgets/          # Reusable widgets
└── main.dart         # App entry point
```

## Imports

### Order

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// 4. Relative imports (in lib/ files)
import '../models/behavior.dart';
import '../providers/library_provider.dart';
```

### Convention

- **In lib/ files**: Use relative imports (`../`)
- **In test files**: Use package imports (`package:pawsight/`)
- **No unused imports**

## Naming Conventions

### Files

- **snake_case**: `chat_screen.dart`, `library_provider.dart`
- One class per file (usually)
- File name matches class name

### Classes

- **PascalCase**: `ChatScreen`, `LibraryProvider`, `Behavior`

### Variables and Methods

- **camelCase**: `isLoading`, `fetchData()`, `selectedMood`
- **Private**: prefix with underscore `_items`, `_applyFilters()`

### Constants

- **camelCase with const**: `const defaultPadding = 16.0`

### Database Columns

- **snake_case**: `behavior_id`, `image_path`, `created_at`

## Type Annotations

### Use Explicit Types

```dart
// ✅ Good
final String name = 'Test';
final List<Behavior> behaviors = [];
final int? nullableId = null;

// ❌ Avoid
var name = 'Test';  // Only use var when type is obvious
dynamic data;  // Avoid dynamic unless necessary
```

### Class Fields

```dart
class MyClass {
  // ✅ Use final for immutable fields
  final String name;
  final int id;
  
  // ✅ const constructor when possible
  const MyClass({required this.name, required this.id});
}
```

## Async/Await

### Use async/await, not .then()

```dart
// ✅ Good
Future<void> fetchData() async {
  try {
    final response = await http.get(uri);
    final data = json.decode(response.body);
    return data;
  } catch (e) {
    print('Error: $e');
  }
}

// ❌ Bad
Future<void> fetchData() {
  return http.get(uri).then((response) {
    return json.decode(response.body);
  }).catchError((e) {
    print('Error: $e');
  });
}
```

### Always wrap in try/catch

```dart
Future<void> riskyOperation() async {
  try {
    await someAsyncCall();
  } catch (e) {
    // Handle error
  }
}
```

## Strings

### Use single quotes

```dart
// ✅ Good
const String message = 'Hello';
const Text('Welcome');

// ❌ Bad (unless string contains single quote)
const String message = "Hello";
```

### Triple quotes for multiline/SQL

```dart
const String sql = '''
  CREATE TABLE behaviors (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
  )
''';
```

## State Management (Provider)

### Private fields, public getters

```dart
class MyProvider extends ChangeNotifier {
  // ✅ Good
  List<Item> _items = [];
  List<Item> get items => _items;
  
  // ❌ Bad
  List<Item> items = [];
}
```

### Always notifyListeners()

```dart
void updateValue(String newValue) {
  _value = newValue;
  notifyListeners();  // Required!
}
```

### Toggle pattern

```dart
void toggleFilter(String? value) {
  _filter = _filter == value ? null : value;
  notifyListeners();
}
```

## Widget Construction

### Use const

```dart
// ✅ Good - prevents rebuilds
const Text('Static text')
const SizedBox(height: 16)
const Icon(Icons.star)

// Widget with const constructor
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Hello');
  }
}
```

### Small, focused widgets

```dart
// ✅ Good - composed from smaller widgets
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      _HeaderWidget(),
      _ContentWidget(),
      _FooterWidget(),
    ],
  );
}

// ❌ Bad - everything in one method
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // 100 lines of nested widgets...
    ],
  );
}
```

## Error Handling

### User-friendly messages

```dart
String _getErrorMessage(dynamic error) {
  if (error is SocketException) {
    return 'No internet connection';
  } else if (error is TimeoutException) {
    return 'Request timed out';
  } else {
    return 'An error occurred';
  }
}
```

## Comments

### When to comment

```dart
// ✅ Good - explain WHY, not WHAT
// Toggle filter: if same value clicked, clear the filter
_selectedMood = mood == _selectedMood ? null : mood;

// ✅ Good - document complex logic
/// Filters behaviors by search query and selected mood.
/// Returns only behaviors that match both criteria.
void _applyFilters() { ... }

// ❌ Bad - obvious comment
// Set loading to true
_isLoading = true;
```

## Code Organization

### One responsibility per class

```dart
// ✅ Good
class BehaviorService {
  Future<List<Behavior>> fetchBehaviors() { ... }
}

class BehaviorProvider {
  void filterBehaviors() { ... }
}

// ❌ Bad - too many responsibilities
class BehaviorManager {
  Future<List<Behavior>> fetchBehaviors() { ... }
  void filterBehaviors() { ... }
  void saveBehavior() { ... }
  void validateInput() { ... }
}
```

### Extract methods

```dart
// ✅ Good
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: _buildBody(),
  );
}

Widget _buildAppBar() { ... }
Widget _buildBody() { ... }

// ❌ Bad
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // 30 lines of complex AppBar setup
    ),
    body: Column(
      // 100 lines of body content
    ),
  );
}
```

## Flutter Commands

From working directory `pawsight/`:

```bash
# Run app
flutter run

# Build
flutter build apk  # Android
flutter build ios  # iOS

# Test
flutter test                    # All tests
flutter test test/file_test.dart  # Single file

# Analyze
flutter analyze

# Format
dart format .
```

## Checklist for New Code

- [ ] Imports organized (dart → flutter → package → relative)
- [ ] File and variable names follow conventions
- [ ] Private fields with public getters (Provider)
- [ ] notifyListeners() called after state changes
- [ ] Async code uses async/await with try/catch
- [ ] Single quotes for strings
- [ ] const constructors where possible
- [ ] No unused imports
- [ ] Comments explain WHY, not WHAT
- [ ] Methods are small and focused
- [ ] flutter analyze passes with no issues
