# MVVM Architecture for PawSight

This document defines the MVVM (Model-View-ViewModel) architecture pattern as implemented in PawSight.

## Architecture Overview

```
View (UI)  ←→  ViewModel (Provider)  ←→  Model (Data + Services)
```

### Separation of Concerns

- **View**: Flutter widgets, UI rendering only
- **ViewModel**: Business logic, state management (Provider)
- **Model**: Data structures, data access (Services, DatabaseHelper)

## Layer Responsibilities

### Model Layer

**Purpose**: Represents data and handles data access

**Components**:
- **Data Classes** (`lib/models/`): Plain Dart classes
- **Services** (`lib/services/`): Database and API access

**Rules**:
- No UI code
- No business logic (just data transformation)
- Immutable data classes preferred
- Implement serialization (toMap/fromMap, toJson/fromJson)

**Example Model**:
```dart
// lib/models/behavior.dart
class Behavior {
  final int id;
  final String name;
  final String category;
  final String mood;
  final String description;
  final String imagePath;

  const Behavior({
    required this.id,
    required this.name,
    required this.category,
    required this.mood,
    required this.description,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'mood': mood,
      'description': description,
      'image_path': imagePath,
    };
  }

  factory Behavior.fromMap(Map<String, dynamic> map) {
    return Behavior(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      mood: map['mood'] as String,
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
    );
  }
}
```

**Example Service**:
```dart
// lib/services/database_helper.dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<Behavior>> getBehaviors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('behaviors');
    return List.generate(maps.length, (i) => Behavior.fromMap(maps[i]));
  }
}
```

### ViewModel Layer (Provider)

**Purpose**: Manages UI state and business logic

**Components**:
- **Providers** (`lib/providers/`): ChangeNotifier classes

**Rules**:
- Extends ChangeNotifier
- Private state fields with public getters
- Methods for state mutations call notifyListeners()
- Handles async operations (API calls, database queries)
- Manages loading and error states
- No direct UI code (no widgets, no BuildContext in state)

**Structure**:
```dart
// lib/providers/library_provider.dart
class LibraryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Private state
  List<Behavior> _behaviors = [];
  List<Behavior> _filteredBehaviors = [];
  String _searchQuery = '';
  String? _selectedMood;
  bool _isLoading = false;
  String? _error;

  // Public getters (immutable access)
  List<Behavior> get behaviors => _filteredBehaviors;
  String get searchQuery => _searchQuery;
  String? get selectedMood => _selectedMood;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods (mutations call notifyListeners)
  Future<void> loadBehaviors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _behaviors = await _dbHelper.getBehaviors();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setMoodFilter(String? mood) {
    _selectedMood = mood == _selectedMood ? null : mood;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredBehaviors = _behaviors.where((behavior) {
      final matchesSearch = _searchQuery.isEmpty ||
          behavior.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          behavior.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesMood = _selectedMood == null || behavior.mood == _selectedMood;

      return matchesSearch && matchesMood;
    }).toList();
  }
}
```

**Key Patterns**:

1. **Loading State Pattern**:
```dart
Future<void> fetchData() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final data = await _service.fetch();
    _data = data;
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}
```

2. **Toggle Filter Pattern**:
```dart
void toggleFilter(String value) {
  _filter = _filter == value ? null : value;
  _applyFilters();
  notifyListeners();
}
```

3. **Derived State Pattern**:
```dart
// Don't store filtered list separately if it can be computed
List<Item> get filteredItems {
  return _items.where((item) => item.matches(_filter)).toList();
}
```

### View Layer

**Purpose**: Renders UI and captures user input

**Components**:
- **Screens** (`lib/screens/`): Full-page widgets
- **Widgets** (`lib/widgets/`): Reusable UI components

**Rules**:
- Use StatelessWidget with Provider
- No business logic in widgets
- Use Consumer or context.watch to access Provider
- Use context.read for actions only
- Handle loading, error, and empty states
- Keep build methods small and readable

**Structure**:
```dart
// lib/screens/library_screen.dart
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior Library'),
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, provider, child) {
          // Handle loading state
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.loadBehaviors(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Handle empty state
          if (provider.behaviors.isEmpty) {
            return const Center(child: Text('No behaviors found'));
          }

          // Main content
          return Column(
            children: [
              _SearchBar(provider: provider),
              _FilterChips(provider: provider),
              Expanded(
                child: _BehaviorList(behaviors: provider.behaviors),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## Data Flow

### View → ViewModel → Model

User interacts with View → View calls Provider method → Provider updates Model/Service → Provider updates state → Provider calls notifyListeners() → View rebuilds

```dart
// User taps button in View
ElevatedButton(
  onPressed: () {
    // 1. View calls Provider method
    context.read<LibraryProvider>().loadBehaviors();
  },
  child: const Text('Load'),
)

// 2. Provider method executes
Future<void> loadBehaviors() async {
  // 3. Provider calls Service/Model
  _behaviors = await _dbHelper.getBehaviors();
  
  // 4. Provider updates state
  _isLoading = false;
  
  // 5. Provider notifies listeners
  notifyListeners();
}

// 6. View rebuilds automatically
Consumer<LibraryProvider>(
  builder: (context, provider, child) {
    return ListView(
      children: provider.behaviors.map(...).toList(),
    );
  },
)
```

## Dependency Injection

### Provider Registration

```dart
// lib/main.dart
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

### Accessing Providers

```dart
// In widgets - listen to changes
final provider = context.watch<LibraryProvider>();

// In widgets - one-time read for actions
context.read<LibraryProvider>().doSomething();

// More granular control
Consumer<LibraryProvider>(
  builder: (context, provider, child) {
    return Text(provider.data);
  },
)
```

## Testing

### Test Each Layer Independently

**Model Tests**:
```dart
test('Behavior.fromMap creates object correctly', () {
  final map = {'id': 1, 'name': 'Test', ...};
  final behavior = Behavior.fromMap(map);
  expect(behavior.id, 1);
  expect(behavior.name, 'Test');
});
```

**Provider Tests**:
```dart
test('loadBehaviors updates state', () async {
  final provider = LibraryProvider();
  await provider.loadBehaviors();
  expect(provider.isLoading, false);
  expect(provider.behaviors, isNotEmpty);
});
```

**Widget Tests**:
```dart
testWidgets('displays behaviors from provider', (tester) async {
  final provider = LibraryProvider();
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(home: LibraryScreen()),
    ),
  );
  expect(find.byType(ListView), findsOneWidget);
});
```

## Common Violations to Avoid

### ❌ Business Logic in View

```dart
// BAD
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyProvider>();
    
    // Business logic in View!
    final filteredData = provider.data
        .where((item) => item.isActive)
        .toList();
    
    return ListView(children: ...);
  }
}
```

### ✅ Correct: Logic in ViewModel

```dart
// GOOD - ViewModel
class MyProvider extends ChangeNotifier {
  List<Item> get activeItems {
    return _data.where((item) => item.isActive).toList();
  }
}

// View
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyProvider>();
    return ListView(
      children: provider.activeItems.map(...).toList(),
    );
  }
}
```

### ❌ UI Code in ViewModel

```dart
// BAD
class MyProvider extends ChangeNotifier {
  void showError(BuildContext context) {  // BuildContext in Provider!
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

### ✅ Correct: UI Stays in View

```dart
// GOOD - ViewModel
class MyProvider extends ChangeNotifier {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
}

// View
Consumer<MyProvider>(
  builder: (context, provider, child) {
    if (provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      });
    }
    return MyWidget();
  },
)
```

### ❌ Direct Database/API Calls from View

```dart
// BAD
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper().getBehaviors(),  // Direct DB call!
      builder: (context, snapshot) { ... },
    );
  }
}
```

### ✅ Correct: Calls Through ViewModel

```dart
// GOOD - ViewModel handles data access
class LibraryProvider extends ChangeNotifier {
  Future<void> loadBehaviors() async {
    _behaviors = await DatabaseHelper().getBehaviors();
    notifyListeners();
  }
}

// View consumes ViewModel state
Consumer<LibraryProvider>(
  builder: (context, provider, child) {
    return ListView(
      children: provider.behaviors.map(...).toList(),
    );
  },
)
```

## Summary

**Model**: Data + Data Access (no UI, no logic)  
**ViewModel**: State + Business Logic (no UI)  
**View**: UI Rendering (no logic, no data access)

**Key Principles**:
1. Clear separation of concerns
2. View observes ViewModel through Provider
3. ViewModel manipulates Model/Services
4. Each layer testable independently
5. Changes flow: User → View → ViewModel → Model → ViewModel → View
