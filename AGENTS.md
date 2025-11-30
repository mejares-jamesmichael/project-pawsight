# PawSight Agent Guidelines

## Project Context
Flutter app (SDK ^3.9.2) for cat body language interpretation. MVVM architecture with Provider state management, SQLite offline storage, n8n webhook for AI chat. Working directory: `pawsight/`

## Commands
- **Run**: `cd pawsight && flutter run`
- **Build**: `flutter build apk` (Android) or `flutter build ios` (iOS)
- **Test all**: `cd pawsight && flutter test`
- **Test single**: `flutter test test/database_test.dart`
- **Lint**: `flutter analyze`
- **Format**: `dart format .`

## Architecture
- **Models**: `lib/models/` - Data classes with `toMap()`/`fromMap()` for SQLite
- **Services**: `lib/services/` - Database/API access (Singleton pattern)
- **Providers**: `lib/providers/` - ChangeNotifier ViewModels, call `notifyListeners()` after state changes

## Code Style
- **Imports**: Relative (`../`) in lib/, package imports (`package:pawsight/`) in tests
- **Naming**: camelCase variables/methods, PascalCase classes, snake_case DB columns
- **Types**: `final` for class fields, `const` constructors for stateless widgets
- **Async**: `async`/`await` over `.then()`, wrap in try/catch
- **Strings**: Single quotes, triple quotes for SQL/multiline
- **State**: Private fields (`_field`), public getters, toggle filters by comparing to current value
