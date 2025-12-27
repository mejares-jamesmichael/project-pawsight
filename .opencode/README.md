# PawSight .opencode System

## Overview

This `.opencode` system provides AI-powered development assistance for PawSight, a Flutter mobile app for cat behavior interpretation.

**Architecture**: MVVM (Model-View-ViewModel)  
**State Management**: Provider  
**Database**: SQLite  
**Working Directory**: `pawsight/`

## Quick Start

### Custom Commands

Use these slash commands for common operations:

```bash
# Build a complete feature
/build-feature quiz-system

# Integrate an API
/add-api cat-facts https://catfact.ninja

# Create just a screen
/create-screen favorites

# Add a model class
/add-model Quiz id:int,question:string,answer:string

# Review code quality
/review-code lib/screens/chat_screen.dart
```

### Natural Language

You can also use natural language:

```
"Create a favorites feature for saving behaviors"
"Integrate the Cat Facts API"
"Review my chat provider code"
"Help me implement the quiz feature"
```

## System Architecture

### Main Orchestrator

**`flutter-feature-orchestrator`** - Primary entry point
- Analyzes requests and routes to specialists
- Manages workflow execution
- Coordinates multi-agent tasks

### Specialized Agents

1. **feature-builder** - Complete feature implementation
   - Scaffolds MVVM structure
   - Creates screens, providers, models
   
2. **api-integration-specialist** - API integrations
   - HTTP services with error handling
   - Response models
   - Authentication support

3. **code-reviewer** - Quality assurance
   - Reviews against standards
   - Identifies anti-patterns
   - Provides actionable feedback

4. **test-generator** - Test coverage
   - Unit tests for models/providers
   - Widget tests for screens
   - Mocking and fixtures

## Context System

### Domain Knowledge
- `flutter-patterns.md` - Flutter best practices
- `mvvm-architecture.md` - MVVM implementation guide
- `provider-state-management.md` - Provider patterns
- `sqlite-integration.md` - Database patterns

### Process Workflows
- `feature-development-workflow.md` - Step-by-step feature guide
- `api-integration-process.md` - API integration checklist
- `code-review-checklist.md` - Quality assurance steps

### Standards
- `code-style-guide.md` - Naming, formatting, conventions
- `error-handling-standards.md` - Error patterns
- `file-organization.md` - Project structure rules

### Templates
- `screen-template.md` - MVVM screen boilerplate
- `provider-template.md` - ViewModel template
- `model-template.md` - Model with SQLite serialization
- `http-service-template.md` - API service patterns

## Example Workflows

### Build a New Feature

```bash
/build-feature quiz-system
```

Creates:
- `lib/screens/quiz_system_screen.dart`
- `lib/providers/quiz_system_provider.dart`
- `lib/models/quiz.dart`
- Provider registration in `main.dart`

### Integrate an API

```bash
/add-api cat-facts https://catfact.ninja
```

Creates:
- `lib/services/cat_facts_service.dart`
- `lib/models/cat_facts_models.dart`
- Example usage in Provider

Then integrate with Provider:
```dart
// In Provider
final service = CatFactsService();
final fact = await service.fetchFact();
```

### Review and Test

```bash
/review-code lib/providers/quiz_provider.dart
```

Then generate tests:
```bash
"Generate tests for QuizProvider"
```

## Development Guidelines

### Code Style (from AGENTS.md)

- **Imports**: Relative (`../`) in lib/, package (`package:pawsight/`) in tests
- **Naming**: camelCase vars, PascalCase classes, snake_case files/DB columns
- **Types**: `final` for fields, `const` constructors
- **Async**: `async/await` over `.then()`, wrap in try/catch
- **Strings**: Single quotes, triple quotes for SQL

### MVVM Pattern

- **Model**: Data classes with toMap/fromMap
- **ViewModel**: Provider (ChangeNotifier) with private fields, public getters
- **View**: StatelessWidget with Consumer

### Provider Rules

1. Private fields (`_field`), public getters
2. Always call `notifyListeners()` after state changes
3. Use `context.watch` in build methods
4. Use `context.read` for actions only

## Session Management

The system tracks ongoing feature work in `.opencode/sessions/`. When you start a feature, a session file is created to maintain context across interactions.

**Session Structure**:
```markdown
# Feature Name Session

**Status**: in_progress | completed | blocked

## Objective
Feature description and goals

## Progress
- [x] Completed task
- [ ] In progress task

## Files Modified
- lib/screens/...
- lib/providers/...

## Decisions Made
- Decision: Rationale

## Next Steps
- Action items
```

## Testing Your Changes

```bash
cd pawsight

# Run the app
flutter run

# Run tests
flutter test

# Lint
flutter analyze

# Format
dart format .
```

## Project Structure

```
pawsight/
├── lib/
│   ├── models/           # Data classes
│   ├── services/         # Database/API access
│   ├── providers/        # ViewModels (Provider)
│   ├── screens/          # Screen widgets
│   ├── widgets/          # Reusable widgets
│   └── main.dart
├── test/                 # Unit and widget tests
└── integration_test/     # Integration tests
```

## Tips for Success

1. **Use commands for common tasks** - Faster and more consistent
2. **Review generated code** - Use `/review-code` before committing
3. **Test incrementally** - Run `flutter run` after each feature
4. **Follow patterns** - Check context files for guidance
5. **Ask questions** - Natural language works great

## Getting Help

### View Available Commands
```
"What commands are available?"
"Show me all slash commands"
```

### Understand a Pattern
```
"How should I structure a Provider?"
"Show me an example of MVVM in PawSight"
```

### Troubleshoot Issues
```
"Why isn't my Provider updating the UI?"
"How do I handle errors in async operations?"
```

## Next Steps

1. Try a command: `/build-feature test-feature`
2. Review the context files in `.opencode/context/`
3. Explore the agent definitions in `.opencode/agent/`
4. Start building your features!

---

**System Version**: 1.0.0  
**Created**: 2025-12-27  
**Working Directory**: `pawsight/`
