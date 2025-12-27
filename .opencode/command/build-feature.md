# /build-feature Command

**Syntax**: `/build-feature {feature_name}`

**Description**: Scaffolds a complete feature with MVVM pattern including screen, provider, model (if needed), and service (if needed).

**Example**: `/build-feature quiz-system`

## What This Command Does

Creates a complete feature structure following PawSight's MVVM architecture:
- Screen widget (StatelessWidget)
- Provider ViewModel (ChangeNotifier)
- Model class with SQLite serialization (optional)
- Service layer for data access (optional)
- Navigation setup
- Provider registration

## Usage

```bash
/build-feature {feature-name}
```

### Examples

```bash
/build-feature favorites
# Creates: FavoritesScreen, FavoritesProvider, navigation

/build-feature quiz
# Creates: QuizScreen, QuizProvider, Quiz model, QuizService

/build-feature photo-gallery
# Creates: PhotoGalleryScreen, PhotoGalleryProvider
```

## What Gets Created

### 1. Screen Widget
**Location**: `lib/screens/{feature_name}_screen.dart`

```dart
class {FeatureName}Screen extends StatelessWidget {
  const {FeatureName}Screen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{Feature Name}')),
      body: Consumer<{FeatureName}Provider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          return {BuildMainContent}(provider);
        },
      ),
    );
  }
}
```

### 2. Provider ViewModel
**Location**: `lib/providers/{feature_name}_provider.dart`

```dart
class {FeatureName}Provider extends ChangeNotifier {
  // Private state
  bool _isLoading = false;
  String? _error;
  
  // Public getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods with notifyListeners
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Fetch/process data
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

### 3. Model (if applicable)
**Location**: `lib/models/{model_name}.dart`

Includes toMap/fromMap for SQLite integration.

### 4. Service (if applicable)
**Location**: `lib/services/{service_name}.dart`

Singleton pattern for database or API access.

### 5. Provider Registration
Updates `lib/main.dart` to register the new Provider.

## When to Use

- Starting a new feature from scratch
- Need complete MVVM structure
- Want consistent architecture

## Routing

This command routes to the **Feature Builder** agent with:
- Context: MVVM architecture, Provider patterns, code style
- Templates: Screen, Provider, Model templates
- Working directory: `pawsight/`

## After Execution

1. **Test the feature**: `cd pawsight && flutter run`
2. **Generate tests**: Use test-generator for coverage
3. **Review code**: `/review-code lib/screens/{feature}_screen.dart`
4. **Integrate**: Connect to existing navigation

## Related Commands

- `/create-screen` - Create just a screen with Provider
- `/add-model` - Add just a model class
- `/review-code` - Review generated code
