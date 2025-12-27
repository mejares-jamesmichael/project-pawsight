# /create-screen Command

**Syntax**: `/create-screen {screen_name}`

**Description**: Generates a screen widget with Provider and MVVM structure.

**Example**: `/create-screen favorites`

## What This Command Does

Creates a single screen with its Provider ViewModel, following MVVM pattern.

## Usage

```bash
/create-screen {screen-name}
```

### Examples

```bash
/create-screen settings
/create-screen profile
/create-screen favorites
```

## What Gets Created

1. **Screen Widget**: `lib/screens/{name}_screen.dart`
2. **Provider**: `lib/providers/{name}_provider.dart`
3. **Provider Registration**: Updated in `main.dart`

## Routes To

Feature Builder agent

## Related Commands

- `/build-feature` - Full feature with models and services
- `/add-model` - Add a model class separately
