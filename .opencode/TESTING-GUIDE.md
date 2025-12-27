# Testing Guide

How to test and verify your `.opencode` system for PawSight.

## System Testing Checklist

### 1. Test Main Orchestrator

**Objective**: Verify orchestrator routes correctly

```bash
# Test 1: Simple question (no routing needed)
"How do I use Provider in Flutter?"
Expected: Direct answer, no delegation

# Test 2: Feature request (routes to Feature Builder)
"/build-feature test-feature"
Expected: Routes to Feature Builder, creates files

# Test 3: API request (routes to API Specialist)
"/add-api test-api https://example.com"
Expected: Routes to API Specialist, creates service

# Test 4: Review request (routes to Code Reviewer)
"/review-code lib/models/behavior.dart"
Expected: Routes to Code Reviewer, provides feedback
```

### 2. Test Custom Commands

**Test each command individually**:

#### /build-feature
```bash
/build-feature favorites

Expected Output:
- lib/screens/favorites_screen.dart
- lib/providers/favorites_provider.dart
- Provider registered in main.dart
- Usage instructions provided
```

#### /add-api
```bash
/add-api cat-facts https://catfact.ninja

Expected Output:
- lib/services/cat_facts_service.dart
- lib/models/cat_facts_models.dart
- Example usage
- Error handling included
```

#### /create-screen
```bash
/create-screen settings

Expected Output:
- lib/screens/settings_screen.dart
- lib/providers/settings_provider.dart
- Provider registered
```

#### /add-model
```bash
/add-model TestModel id:int,name:string,count:int

Expected Output:
- lib/models/test_model.dart
- toMap() and fromMap() methods
- SQLite table definition
```

#### /review-code
```bash
/review-code lib/providers/library_provider.dart

Expected Output:
- Overall assessment
- Issues categorized (critical/important/minor)
- Specific recommendations
- Code examples for fixes
```

### 3. Test Context Loading

**Verify correct context files loaded**:

```bash
# For feature building
/build-feature test
Check logs: Should load MVVM, Provider, Screen template

# For API integration
/add-api test https://example.com
Check logs: Should load API process, Error handling, HTTP template

# For code review
/review-code lib/models/behavior.dart
Check logs: Should load Code style, MVVM, Review checklist
```

### 4. Test Generated Code Quality

**After generating code, verify**:

```bash
cd pawsight

# 1. Code compiles
flutter analyze
# Should show 0 issues for generated code

# 2. Code runs
flutter run
# App should launch without errors

# 3. Formatting
dart format lib/
# Generated code should already be formatted

# 4. Standards compliance
# Review generated files manually:
- Imports organized correctly?
- Naming conventions followed?
- const constructors used?
- notifyListeners() called?
```

### 5. Test Workflow Execution

**Test complete feature workflow**:

```bash
# Step 1: Create feature
/build-feature quiz-system

# Step 2: Verify files created
ls lib/screens/quiz_system_screen.dart
ls lib/providers/quiz_system_provider.dart

# Step 3: Test the app
cd pawsight && flutter run

# Step 4: Generate tests
"Generate tests for QuizSystemProvider"

# Step 5: Run tests
flutter test test/providers/quiz_system_provider_test.dart

# Step 6: Review code
/review-code lib/providers/quiz_system_provider.dart

# Step 7: Verify review feedback
# Should provide specific, actionable feedback
```

### 6. Test Session Management

**Test session creation and tracking**:

```bash
# Start a feature
"I want to start building a favorites feature"

# Verify session created
ls .opencode/sessions/
# Should see favorites-session.md

# Continue work in session
"Add a model for the favorites feature"

# Check session updated
cat .opencode/sessions/favorites-session.md
# Should show progress and decisions

# Close session
"The favorites feature is complete"

# Verify session closed
cat .opencode/sessions/favorites-session.md
# Status should be "completed"
```

### 7. Test Error Handling

**Test graceful error handling**:

```bash
# Test 1: Invalid command syntax
/build-feature
Expected: Clear error message, usage example

# Test 2: Invalid file path
/review-code invalid/path.dart
Expected: Error message, file not found

# Test 3: Malformed API URL
/add-api test not-a-url
Expected: Error message, valid URL format shown
```

## Integration Testing

### Test with Real PawSight Features

**Test 1: Chat Feature Integration**

```bash
/add-api n8n-chat https://your-webhook-url

# Verify:
1. Service created with multipart support
2. Handles text + image upload
3. Error handling for network failures
4. Timeout configured (30s for uploads)
```

**Test 2: Behavior Library Enhancement**

```bash
/build-feature favorites

# Verify:
1. Integrates with existing Behavior model
2. Uses DatabaseHelper for storage
3. Follows existing Provider patterns
4. Matches LibraryProvider style
```

**Test 3: API Integration**

```bash
/add-api cat-facts https://catfact.ninja

# Then integrate:
"Integrate cat-facts API into a new daily facts screen"

# Verify:
1. Service and screen work together
2. Error handling in UI
3. Loading states shown
4. Follows MVVM pattern
```

## Verification Checklist

### Generated Code Quality

- [ ] Compiles without errors (flutter analyze)
- [ ] Follows naming conventions
- [ ] Imports organized correctly
- [ ] const constructors used where applicable
- [ ] MVVM pattern followed
- [ ] Provider calls notifyListeners()
- [ ] Error handling included
- [ ] Loading states managed
- [ ] No unused imports

### Orchestrator Behavior

- [ ] Routes to correct specialist
- [ ] Loads appropriate context
- [ ] Creates sessions when needed
- [ ] Provides clear output
- [ ] Handles errors gracefully
- [ ] Gives actionable next steps

### Context System

- [ ] Context files load correctly
- [ ] Agents follow context guidelines
- [ ] Standards enforced consistently
- [ ] Templates applied properly

### Commands

- [ ] All 5 commands work
- [ ] Syntax clear and documented
- [ ] Output matches expectations
- [ ] Error messages helpful

## Performance Testing

### Response Times

**Measure agent response times**:

```bash
# Simple command (should be fast)
time: /create-screen test
Expected: < 5 seconds total

# Complex command (may take longer)
time: /build-feature complex-feature
Expected: < 15 seconds total

# Review command
time: /review-code lib/models/behavior.dart
Expected: < 10 seconds
```

### Context Loading

**Measure context loading overhead**:

```bash
# Level 1: 3-5 files
/create-screen test
Expected: Minimal overhead (< 1s)

# Level 2: 6-10 files
/build-feature test
Expected: Moderate overhead (< 2s)

# Level 3: 12+ files
Complex feature with full context
Expected: Higher overhead (< 3s)
```

## Troubleshooting

### Common Issues

**Issue**: Code doesn't compile
- **Check**: Run `flutter analyze` for specific errors
- **Fix**: Review generated code against standards
- **Prevention**: Update context files with correct patterns

**Issue**: Provider doesn't update UI
- **Check**: notifyListeners() called?
- **Check**: Using context.watch or Consumer?
- **Fix**: Add missing notifyListeners() calls

**Issue**: Orchestrator routes to wrong agent
- **Check**: Request keywords and patterns
- **Fix**: Update routing logic in orchestrator
- **Prevention**: Test with various phrasings

**Issue**: Context not loading
- **Check**: File paths in agent definitions
- **Check**: Files exist in .opencode/context/
- **Fix**: Verify context file locations

## Success Criteria

Your `.opencode` system is working correctly if:

1. ✅ All 5 commands execute successfully
2. ✅ Generated code compiles and runs
3. ✅ Code follows PawSight standards
4. ✅ Orchestrator routes correctly
5. ✅ Context loads appropriately
6. ✅ Sessions track work properly
7. ✅ Reviews provide actionable feedback
8. ✅ Tests can be generated
9. ✅ Integration with existing code works
10. ✅ Error handling is graceful

## Continuous Testing

**Regular checks** to maintain system quality:

- **Weekly**: Test all commands
- **Before major features**: Verify routing
- **After context updates**: Test affected agents
- **Monthly**: Full integration test

## Feedback Loop

**Improve the system** based on usage:

1. Track which commands used most
2. Identify common errors
3. Update context files with learnings
4. Refine agent routing logic
5. Add new patterns to templates

---

**Happy Testing!** 🎉

If all tests pass, your `.opencode` system is production-ready for PawSight development.
