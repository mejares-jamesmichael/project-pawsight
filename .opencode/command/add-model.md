# /add-model Command

**Syntax**: `/add-model {model_name} {fields}`

**Description**: Creates a model class with SQLite serialization (toMap/fromMap).

**Example**: `/add-model Quiz id:int,question:string,answer:string,difficulty:string`

## What This Command Does

Creates a model class with:
- Typed fields
- toMap() method for SQLite
- fromMap() factory constructor
- const constructor

## Usage

```bash
/add-model {ModelName} {field1:type,field2:type,...}
```

### Field Types

- `int` - Integer
- `string` - String
- `double` - Double
- `bool` - Boolean
- `datetime` - DateTime (stored as int in SQLite)

### Examples

```bash
/add-model Quiz id:int,question:string,answer:string,points:int

/add-model UserProfile id:int,name:string,email:string,avatar:string

/add-model Favorite id:int,behavior_id:int,created_at:datetime
```

## What Gets Created

**Location**: `lib/models/{model_name}.dart`

```dart
class {ModelName} {
  final int id;
  final String field1;
  // ... other fields
  
  const {ModelName}({
    required this.id,
    required this.field1,
    // ... other fields
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'field1': field1,
      // ... other fields
    };
  }
  
  factory {ModelName}.fromMap(Map<String, dynamic> map) {
    return {ModelName}(
      id: map['id'] as int,
      field1: map['field1'] as String,
      // ... other fields
    );
  }
}
```

## Database Integration

The agent also provides the SQLite table creation SQL:

```sql
CREATE TABLE {table_name} (
  id INTEGER PRIMARY KEY,
  field1 TEXT NOT NULL,
  field2 INTEGER,
  ...
);
```

## Routes To

Feature Builder agent

## Related Commands

- `/build-feature` - Full feature including model
- `/create-screen` - Screen that uses the model
