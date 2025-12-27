# Flutter Patterns and Best Practices

This document outlines Flutter-specific patterns and best practices for PawSight development.

## Widget Patterns

### StatelessWidget vs StatefulWidget

**Use StatelessWidget** when:
- Widget doesn't manage its own state
- State comes from Provider or parent widget
- Rebuilds triggered by external state changes

```dart
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (context, provider, child) {
        return Text(provider.data);
      },
    );
  }
}
```

**Use StatefulWidget** when:
- Widget manages local UI state (form fields, animations)
- State is not shared with other widgets
- Need lifecycle methods (initState, dispose)

### Const Constructors

Always use `const` constructors when possible for performance:

```dart
// Good
const Text('Hello')
const SizedBox(height: 16)
const Padding(padding: EdgeInsets.all(8))

// Const constructor in custom widget
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Static content');
  }
}
```

### Widget Composition

Break large widgets into smaller, reusable pieces:

```dart
// Bad: Everything in one build method
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: Column(
        children: [
          // 100 lines of complex UI
        ],
      ),
    );
  }
}

// Good: Composed from smaller widgets
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: Column(
        children: [
          _HeaderSection(),
          _ContentSection(),
          _FooterSection(),
        ],
      ),
    );
  }
}
```

## State Management with Provider

### Provider Setup

```dart
// main.dart
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

### Accessing Provider

**In Widgets** - Use Consumer or context.watch:

```dart
// Option 1: Consumer (more granular rebuilds)
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return Text(provider.data);
  },
)

// Option 2: context.watch (rebuilds whole widget)
@override
Widget build(BuildContext context) {
  final provider = context.watch<MyProvider>();
  return Text(provider.data);
}

// Option 3: Selector (rebuild only when specific value changes)
Selector<MyProvider, String>(
  selector: (context, provider) => provider.specificValue,
  builder: (context, value, child) {
    return Text(value);
  },
)
```

**For Actions** - Use context.read (doesn't listen for changes):

```dart
ElevatedButton(
  onPressed: () {
    context.read<MyProvider>().doSomething();
  },
  child: const Text('Action'),
)
```

### Provider Best Practices

1. **Private fields, public getters**
```dart
class MyProvider extends ChangeNotifier {
  List<Item> _items = [];
  List<Item> get items => _items;  // Immutable access
}
```

2. **Always call notifyListeners()**
```dart
void updateData(String newData) {
  _data = newData;
  notifyListeners();  // Critical!
}
```

3. **Handle loading and error states**
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

## Async Operations

### Use async/await, not .then()

```dart
// Bad
Future<void> fetchData() {
  return http.get(uri).then((response) {
    return json.decode(response.body);
  }).then((data) {
    _processData(data);
  }).catchError((error) {
    _handleError(error);
  });
}

// Good
Future<void> fetchData() async {
  try {
    final response = await http.get(uri);
    final data = json.decode(response.body);
    _processData(data);
  } catch (error) {
    _handleError(error);
  }
}
```

### Always use try/catch

```dart
Future<void> riskyOperation() async {
  try {
    await someAsyncCall();
  } catch (e) {
    // Handle error appropriately
    print('Error: $e');
    rethrow;  // If caller needs to know
  }
}
```

## Navigation

### Named Routes (for simple navigation)

```dart
// Define routes in MaterialApp
MaterialApp(
  routes: {
    '/': (context) => HomeScreen(),
    '/library': (context) => LibraryScreen(),
    '/chat': (context) => ChatScreen(),
  },
)

// Navigate
Navigator.pushNamed(context, '/library');
```

### Direct Routes (for passing data)

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailScreen(item: item),
  ),
);
```

## Performance Optimization

### ListView.builder for Long Lists

```dart
// Bad: Builds all items at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// Good: Builds items lazily as needed
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(items[index]);
  },
)
```

### Avoid Expensive Operations in build()

```dart
// Bad
@override
Widget build(BuildContext context) {
  final processedData = heavyComputation(data);  // Runs every rebuild!
  return Text(processedData);
}

// Good
class MyWidget extends StatelessWidget {
  final String processedData;
  
  MyWidget({required String data}) 
      : processedData = heavyComputation(data);  // Runs once
  
  @override
  Widget build(BuildContext context) {
    return Text(processedData);
  }
}
```

### Use const where possible

```dart
// Prevents unnecessary rebuilds
const Divider()
const SizedBox(height: 16)
const Icon(Icons.star)
```

## Error Handling

### User-Friendly Error Messages

```dart
String getErrorMessage(dynamic error) {
  if (error is SocketException) {
    return 'No internet connection. Please check your network.';
  } else if (error is TimeoutException) {
    return 'Request timed out. Please try again.';
  } else if (error is FormatException) {
    return 'Invalid data received from server.';
  } else {
    return 'An unexpected error occurred. Please try again.';
  }
}
```

### Show Errors in UI

```dart
Consumer<MyProvider>(
  builder: (context, provider, child) {
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(provider.error!),
            ElevatedButton(
              onPressed: provider.retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    // ... rest of UI
  },
)
```

## Code Organization

### Import Order

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// 4. Relative imports
import '../models/behavior.dart';
import '../providers/library_provider.dart';
```

### File Naming

- snake_case for file names
- One class per file (usually)
- File name matches class name

```
behavior.dart         -> Behavior class
library_provider.dart -> LibraryProvider class
chat_screen.dart      -> ChatScreen class
```

## Testing Patterns

### Testable Widget Structure

```dart
// Make widgets testable by accepting dependencies
class MyScreen extends StatelessWidget {
  final MyProvider? provider;  // Optional for testing
  
  const MyScreen({super.key, this.provider});
  
  @override
  Widget build(BuildContext context) {
    final actualProvider = provider ?? context.watch<MyProvider>();
    return Text(actualProvider.data);
  }
}

// In tests
testWidgets('test description', (tester) async {
  final testProvider = MyProvider();
  await tester.pumpWidget(
    MaterialApp(
      home: MyScreen(provider: testProvider),
    ),
  );
  // ... assertions
});
```

## Common Pitfalls to Avoid

1. **Using context.read in build()** - Use context.watch or Consumer
2. **Forgetting notifyListeners()** - Provider won't update UI
3. **Not handling async errors** - App will crash
4. **Mutable public fields in Provider** - Breaks encapsulation
5. **Heavy computation in build()** - Performance issues
6. **Not using const** - Unnecessary rebuilds
7. **Tight coupling** - Hard to test and maintain

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)
