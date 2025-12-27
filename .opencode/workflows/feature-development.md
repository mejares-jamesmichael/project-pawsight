# Feature Development Workflow

Complete workflow for implementing new features in PawSight following MVVM architecture.

## Workflow Stages

### 1. Discovery & Planning

**Objective**: Understand requirements and plan architecture

**Steps**:
1. Clarify feature requirements
   - What problem does this solve?
   - What screens/UI are needed?
   - What data needs to be managed?
   - What external services (API, database)?

2. Identify components needed
   - [ ] Screen widget(s)
   - [ ] Provider ViewModel
   - [ ] Model class(es)
   - [ ] Service layer (API/database)
   - [ ] Navigation changes

3. Plan data flow
   - User interaction → View → ViewModel → Model → ViewModel → View

4. Check existing patterns
   - Review similar features in codebase
   - Identify reusable components

**Output**: Clear understanding of scope and components

---

### 2. Design

**Objective**: Design component structure and interfaces

**Steps**:
1. Design data model
   ```dart
   class MyModel {
     final int id;
     final String field;
     // Define all fields
   }
   ```

2. Design ViewModel state
   ```dart
   class MyProvider extends ChangeNotifier {
     // What state does this feature need?
     List<MyModel> _items = [];
     bool _isLoading = false;
     String? _error;
     String? _selectedFilter;
     
     // What methods?
     Future<void> loadItems()
     void setFilter(String? filter)
   }
   ```

3. Design screen hierarchy
   ```
   MyScreen
   ├── AppBar
   ├── SearchBar (optional)
   ├── FilterChips (optional)
   └── Content
       ├── Loading indicator
       ├── Error message
       ├── Empty state
       └── Item list
   ```

4. Define navigation
   - Where does user come from?
   - How to navigate to this screen?
   - Where can user go from here?

**Output**: Component designs and interfaces

---

### 3. Implementation

**Objective**: Build the feature following MVVM pattern

**Sequence**:

#### 3.1 Create Model (if needed)

**File**: `lib/models/{name}.dart`

```dart
class MyModel {
  final int id;
  final String name;
  // ... fields
  
  const MyModel({
    required this.id,
    required this.name,
  });
  
  // For SQLite
  Map<String, dynamic> toMap() { ... }
  factory MyModel.fromMap(Map<String, dynamic> map) { ... }
  
  // For API/JSON
  Map<String, dynamic> toJson() { ... }
  factory MyModel.fromJson(Map<String, dynamic> json) { ... }
}
```

#### 3.2 Create Service (if needed)

**File**: `lib/services/{name}_service.dart`

```dart
class MyService {
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();
  
  Future<List<MyModel>> fetchData() async {
    try {
      // Fetch from database or API
      return data;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
```

#### 3.3 Create Provider ViewModel

**File**: `lib/providers/{name}_provider.dart`

```dart
class MyProvider extends ChangeNotifier {
  final MyService _service = MyService();
  
  // Private state
  List<MyModel> _items = [];
  bool _isLoading = false;
  String? _error;
  
  // Public getters
  List<MyModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _items = await _service.fetchData();
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

#### 3.4 Create Screen Widget

**File**: `lib/screens/{name}_screen.dart`

```dart
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: Consumer<MyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: provider.loadItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (provider.items.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          
          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              return _buildItem(provider.items[index]);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildItem(MyModel item) {
    return ListTile(
      title: Text(item.name),
      onTap: () => _handleTap(item),
    );
  }
}
```

#### 3.5 Register Provider

**File**: `lib/main.dart`

```dart
MultiProvider(
  providers: [
    // ... existing providers
    ChangeNotifierProvider(create: (_) => MyProvider()),
  ],
  child: const MyApp(),
)
```

#### 3.6 Set Up Navigation

Add route or navigation logic:

```dart
// Named route
'/my-feature': (context) => const MyScreen(),

// Or direct navigation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MyScreen()),
);
```

**Output**: Complete feature implementation

---

### 4. Testing

**Objective**: Verify feature works correctly

**Steps**:

1. **Manual Testing**
   ```bash
   cd pawsight
   flutter run
   ```
   - Test happy path (normal usage)
   - Test error scenarios (no network, empty data)
   - Test edge cases (long text, many items)
   - Test loading states
   - Test navigation

2. **Unit Tests** (Model + Provider)
   ```dart
   test('MyModel.fromMap creates object correctly', () { ... });
   test('MyProvider.loadItems updates state', () async { ... });
   test('MyProvider handles errors correctly', () async { ... });
   ```

3. **Widget Tests** (Screen)
   ```dart
   testWidgets('displays loading indicator', (tester) async { ... });
   testWidgets('displays items when loaded', (tester) async { ... });
   testWidgets('displays error message', (tester) async { ... });
   ```

4. **Integration Test** (Full feature)
   ```dart
   testWidgets('complete user flow', (tester) async {
     // Navigate to screen
     // Interact with UI
     // Verify results
   });
   ```

**Output**: Passing tests, verified functionality

---

### 5. Code Review

**Objective**: Ensure quality and compliance

**Checklist**:

#### Architecture
- [ ] Follows MVVM pattern
- [ ] No business logic in View
- [ ] No UI code in ViewModel
- [ ] Model is just data

#### Provider
- [ ] Extends ChangeNotifier
- [ ] Private fields with public getters
- [ ] notifyListeners() called after state changes
- [ ] Handles loading and error states

#### Code Style
- [ ] Imports organized (dart → flutter → package → relative)
- [ ] Naming conventions followed
- [ ] const constructors used
- [ ] No unused imports

#### Error Handling
- [ ] async/await with try/catch
- [ ] User-friendly error messages
- [ ] Errors displayed in UI

#### Performance
- [ ] No expensive operations in build()
- [ ] ListView.builder for lists
- [ ] Const widgets where possible

**Command**: `/review-code lib/screens/my_screen.dart`

**Output**: Quality validated, issues addressed

---

### 6. Documentation

**Objective**: Document the feature

**Steps**:
1. Add code comments for complex logic
2. Update README if public feature
3. Document API usage (if new API)
4. Add inline documentation
   ```dart
   /// Fetches items from the database and applies current filters.
   /// 
   /// Sets loading state during fetch and error state on failure.
   /// Calls [notifyListeners] when state changes.
   Future<void> loadItems() async { ... }
   ```

**Output**: Well-documented code

---

### 7. Integration & Cleanup

**Objective**: Integrate with app and clean up

**Steps**:
1. Verify navigation from all entry points
2. Test feature in full app context
3. Remove debug code and print statements
4. Format code: `dart format .`
5. Analyze: `flutter analyze`
6. Update session: Mark feature complete

**Output**: Feature integrated and production-ready

---

## Quick Reference

### When to Create Each Component

| Component | When to Create |
|-----------|----------------|
| Model | Need data structure, especially with SQLite/JSON |
| Service | Need database or API access |
| Provider | Always (manages state) |
| Screen | Always (the UI) |
| Widgets | Extract reusable UI components |

### Common Patterns

**Loading Pattern**:
```dart
_isLoading = true; notifyListeners();
try { /* fetch */ _isLoading = false; notifyListeners(); }
catch { _error = e; _isLoading = false; notifyListeners(); }
```

**Filter Pattern**:
```dart
void setFilter(String? value) {
  _filter = _filter == value ? null : value;  // Toggle
  _applyFilters();
  notifyListeners();
}
```

**Search Pattern**:
```dart
void setSearchQuery(String query) {
  _searchQuery = query;
  _applyFilters();
  notifyListeners();
}
```

## Troubleshooting

**Provider not updating UI**:
- Forgot notifyListeners()?
- Using context.read instead of context.watch?
- Consumer not wrapping the right widget?

**State lost on rebuild**:
- Provider registered in main.dart?
- Using StatelessWidget with Consumer?
- Not recreating Provider on every build?

**Async errors crashing app**:
- Missing try/catch around async code?
- Not handling errors in Provider?
- Not displaying errors in UI?

---

**Use this workflow** for all new features in PawSight to ensure consistency and quality.
