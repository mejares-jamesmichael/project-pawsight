# /review-code Command

**Syntax**: `/review-code {file_path}`

**Description**: Reviews Flutter code against PawSight standards and best practices, providing actionable feedback.

**Example**: `/review-code lib/screens/chat_screen.dart`

## What This Command Does

Performs comprehensive code review checking:
- MVVM architecture compliance
- Provider state management correctness
- Code style (naming, imports, types)
- Error handling completeness
- Performance considerations
- Common anti-patterns

## Usage

```bash
/review-code {file-path}
```

### Examples

```bash
/review-code lib/screens/library_screen.dart
# Reviews screen widget

/review-code lib/providers/chat_provider.dart
# Reviews Provider ViewModel

/review-code lib/services/database_helper.dart
# Reviews service class

/review-code lib/models/behavior.dart
# Reviews model class
```

## Review Checklist

### Architecture
- [ ] MVVM separation of concerns maintained
- [ ] No business logic in View
- [ ] No UI code in ViewModel
- [ ] Provider used correctly

### State Management
- [ ] Provider extends ChangeNotifier
- [ ] notifyListeners() called after state changes
- [ ] Private fields with public getters
- [ ] context.watch vs context.read used appropriately

### Code Style
- [ ] Proper import organization
- [ ] Naming conventions followed (camelCase, PascalCase, snake_case)
- [ ] Explicit types used
- [ ] const constructors where possible

### Error Handling
- [ ] async/await with try/catch
- [ ] Loading and error states handled
- [ ] User-friendly error messages

### Performance
- [ ] No expensive operations in build()
- [ ] ListView.builder for long lists
- [ ] Proper widget disposal

## Output Format

```markdown
## Code Review: {file_path}

**Overall Assessment:** Good | Needs Improvement | Critical Issues
**Architecture Compliance:** Compliant | Minor Issues | Non-Compliant

### Summary
Brief assessment of code quality and purpose

### Issues Found

#### 🔴 Critical Issues (X)
Issues that will cause bugs or crashes

1. **Issue Title**
   - Location: Line X
   - Problem: Description
   - Impact: Why critical
   - Fix: Code example

#### 🟡 Important Issues (X)
Standards violations or maintainability concerns

#### 🔵 Minor Issues (X)
Style issues or suggestions

### ✅ Positive Aspects
What's done well

### Recommendations
Prioritized action items

### Next Steps
- [ ] Fix critical issues immediately
- [ ] Address important issues before merge
- [ ] Consider minor issues for refactoring
```

## Common Issues Detected

### Anti-Pattern: context.read in build()

**Problem**: Using context.read in build method won't rebuild on changes

**Fix**: Use context.watch or Consumer instead

### Anti-Pattern: Missing notifyListeners()

**Problem**: Provider state changed but UI doesn't update

**Fix**: Call notifyListeners() after every state modification

### Anti-Pattern: No Error Handling

**Problem**: Async operations without try/catch

**Fix**: Wrap all async operations in try/catch

### Anti-Pattern: Mutable Public Fields

**Problem**: External code can modify state without notifying listeners

**Fix**: Use private fields with public getters

## When to Use

- Before committing new code
- After implementing a feature
- When refactoring existing code
- Regular quality checks

## Routing

This command routes to the **Code Reviewer** agent with:
- Context: Code style guide, MVVM architecture, Provider patterns
- Target file content
- Review checklist

## After Review

1. **Address critical issues**: Fix bugs and crashes immediately
2. **Fix important issues**: Resolve before merging
3. **Consider minor issues**: Queue for refactoring
4. **Re-run review**: After fixes to verify

## Related Commands

- `/build-feature` - Create feature following standards
- `/add-api` - Integrate API with proper patterns
