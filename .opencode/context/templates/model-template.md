# Model Template

Use this template when creating new model classes in PawSight.

## Basic Model with SQLite

```dart
class {ModelName} {
  final int id;
  final String name;
  final String description;
  // Add other fields

  const {ModelName}({
    required this.id,
    required this.name,
    required this.description,
    // Add other fields
  });

  /// Converts model to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      // Add other fields (use snake_case for column names)
    };
  }

  /// Creates model from SQLite Map
  factory {ModelName}.fromMap(Map<String, dynamic> map) {
    return {ModelName}(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      // Add other fields
    );
  }
}
```

## Model with JSON (for APIs)

```dart
class {ModelName} {
  final String id;
  final String name;
  final String description;
  // Add other fields

  const {ModelName}({
    required this.id,
    required this.name,
    required this.description,
  });

  /// Converts model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  /// Creates model from API JSON response
  factory {ModelName}.fromJson(Map<String, dynamic> json) {
    return {ModelName}(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    };
  }
}
```

## Model with Both SQLite and JSON

```dart
class {ModelName} {
  final int id;
  final String name;
  final String description;

  const {ModelName}({
    required this.id,
    required this.name,
    required this.description,
  });

  // SQLite serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory {ModelName}.fromMap(Map<String, dynamic> map) {
    return {ModelName}(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }

  // JSON serialization (for APIs)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory {ModelName}.fromJson(Map<String, dynamic> json) {
    return {ModelName}(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
```

## Model with DateTime

```dart
class {ModelName} {
  final int id;
  final String name;
  final DateTime createdAt;

  const {ModelName}({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,  // Store as int
    };
  }

  factory {ModelName}.fromMap(Map<String, dynamic> map) {
    return {ModelName}(
      id: map['id'] as int,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
```

## Model with Nullable Fields

```dart
class {ModelName} {
  final int id;
  final String name;
  final String? description;  // Nullable
  final int? count;           // Nullable

  const {ModelName}({
    required this.id,
    required this.name,
    this.description,
    this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,  // Can be null
      'count': count,
    };
  }

  factory {ModelName}.fromMap(Map<String, dynamic> map) {
    return {ModelName}(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,  // Nullable cast
      count: map['count'] as int?,
    );
  }
}
```

## SQLite Table Definition

```sql
CREATE TABLE {table_name} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  created_at INTEGER,
  UNIQUE(name)
);
```

## Common Field Types

| Dart Type | SQLite Type | Example |
|-----------|-------------|---------|
| int | INTEGER | id, count, age |
| String | TEXT | name, description, email |
| double | REAL | price, rating, latitude |
| bool | INTEGER | is_active (0 or 1) |
| DateTime | INTEGER | created_at (milliseconds) |

## Rules

1. **Use final** for all fields
2. **Use const constructor** when possible
3. **Proper null safety** (?, !, required)
4. **Snake_case** for database columns
5. **camelCase** for Dart fields
6. **Type casting** in fromMap/fromJson (as int, as String)
7. **Handle nullable fields** appropriately

## Testing

```dart
test('{ModelName}.toMap converts to map correctly', () {
  final model = {ModelName}(id: 1, name: 'Test', description: 'Desc');
  final map = model.toMap();
  
  expect(map['id'], 1);
  expect(map['name'], 'Test');
  expect(map['description'], 'Desc');
});

test('{ModelName}.fromMap creates object correctly', () {
  final map = {'id': 1, 'name': 'Test', 'description': 'Desc'};
  final model = {ModelName}.fromMap(map);
  
  expect(model.id, 1);
  expect(model.name, 'Test');
  expect(model.description, 'Desc');
});
```
