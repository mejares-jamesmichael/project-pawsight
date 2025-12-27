# .opencode System Index

Quick reference guide for navigating the PawSight .opencode system.

## 📁 Directory Structure

```
.opencode/
├── agent/                          # Agent definitions
│   ├── flutter-feature-orchestrator.md   # Main orchestrator
│   └── subagents/                  # Specialized agents
│       ├── feature-builder.md
│       ├── api-integration-specialist.md
│       ├── code-reviewer.md
│       └── test-generator.md
├── command/                        # Custom slash commands
│   ├── build-feature.md
│   ├── add-api.md
│   ├── create-screen.md
│   ├── add-model.md
│   └── review-code.md
├── context/                        # Knowledge base
│   ├── domain/                     # Technical knowledge
│   │   ├── flutter-patterns.md
│   │   ├── mvvm-architecture.md
│   │   └── provider-state-management.md
│   ├── processes/                  # Workflows
│   ├── standards/                  # Quality criteria
│   │   ├── code-style-guide.md
│   │   └── error-handling-standards.md
│   └── templates/                  # Code boilerplate
│       ├── screen-template.md
│       ├── provider-template.md
│       └── model-template.md
├── workflows/                      # Process workflows
│   └── feature-development.md
├── sessions/                       # Project tracking
├── README.md                       # Quick start guide
├── ARCHITECTURE.md                 # System architecture
├── TESTING-GUIDE.md               # Testing procedures
└── INDEX.md                        # This file
```

## 🤖 Agents

### Main Orchestrator
- **flutter-feature-orchestrator**: Primary entry point, routes requests to specialists

### Specialists
1. **feature-builder**: Complete MVVM feature implementation
2. **api-integration-specialist**: External API integration
3. **code-reviewer**: Quality assurance and standards compliance
4. **test-generator**: Test coverage generation

## 🔧 Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `/build-feature` | Complete feature | `/build-feature quiz-system` |
| `/add-api` | Integrate API | `/add-api cat-facts https://catfact.ninja` |
| `/create-screen` | Single screen | `/create-screen settings` |
| `/add-model` | Data model | `/add-model Quiz id:int,question:string` |
| `/review-code` | Quality check | `/review-code lib/screens/home.dart` |

## 📚 Context Files

### Domain Knowledge
- **flutter-patterns.md**: Flutter/Dart best practices
- **mvvm-architecture.md**: MVVM implementation guide
- **provider-state-management.md**: Provider patterns

### Standards
- **code-style-guide.md**: Naming, formatting, conventions
- **error-handling-standards.md**: Error patterns and messaging

### Templates
- **screen-template.md**: MVVM screen boilerplate
- **provider-template.md**: ChangeNotifier ViewModel template
- **model-template.md**: Model with serialization

### Workflows
- **feature-development.md**: Complete feature implementation workflow

## 🚀 Quick Start

### 1. Build Your First Feature
```bash
/build-feature test-feature
```

### 2. Integrate an API
```bash
/add-api cat-facts https://catfact.ninja
```

### 3. Review Code
```bash
/review-code lib/providers/test_provider.dart
```

### 4. Test the App
```bash
cd pawsight
flutter run
```

## 📖 Documentation

### For Users
- **README.md**: Quick start and usage guide
- **INDEX.md**: This file - navigation guide

### For Developers
- **ARCHITECTURE.md**: System design and architecture
- **TESTING-GUIDE.md**: How to test the system

### For Context
- **context/domain/**: Technical knowledge
- **context/standards/**: Quality standards
- **context/templates/**: Code templates
- **workflows/**: Process workflows

## 🎯 Common Tasks

### Create a New Feature
1. Use `/build-feature {name}` command
2. Test with `flutter run`
3. Generate tests
4. Review with `/review-code`

### Integrate an API
1. Use `/add-api {name} {url}` command
2. Integrate service into Provider
3. Create screen to display data
4. Test error handling

### Review and Improve Code
1. Use `/review-code {file}` command
2. Address critical issues
3. Fix important issues
4. Consider minor improvements

## 🔍 Finding Information

### "How do I...?"

| Question | Location |
|----------|----------|
| Use Provider correctly | `context/domain/provider-state-management.md` |
| Follow MVVM pattern | `context/domain/mvvm-architecture.md` |
| Handle errors | `context/standards/error-handling-standards.md` |
| Format code | `context/standards/code-style-guide.md` |
| Create a screen | `context/templates/screen-template.md` |
| Create a provider | `context/templates/provider-template.md` |
| Create a model | `context/templates/model-template.md` |
| Build a feature | `workflows/feature-development.md` |

### "Which agent handles...?"

| Task | Agent |
|------|-------|
| Complete features | feature-builder |
| API integration | api-integration-specialist |
| Code review | code-reviewer |
| Test generation | test-generator |
| General coordination | flutter-feature-orchestrator |

## 📊 System Stats

- **Total Files**: 22 files
- **Agents**: 5 (1 orchestrator + 4 specialists)
- **Commands**: 5 custom slash commands
- **Context Files**: 8 knowledge files
- **Templates**: 3 code templates
- **Workflows**: 1 complete workflow
- **Documentation**: 4 guide files

## 🎓 Learning Path

### Beginner
1. Read **README.md**
2. Try `/build-feature test`
3. Review generated code
4. Run `flutter run`

### Intermediate
1. Read **ARCHITECTURE.md**
2. Understand agent routing
3. Explore context files
4. Try all commands

### Advanced
1. Study agent definitions
2. Understand context allocation
3. Review workflow execution
4. Customize for your needs

## 💡 Tips

1. **Start simple**: Use commands for common tasks
2. **Read context**: Check templates before coding
3. **Follow patterns**: Review existing code
4. **Test frequently**: Run app after changes
5. **Review quality**: Use `/review-code` regularly

## 🔗 External Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [PawSight AGENTS.md](../AGENTS.md)
- [PawSight README.md](../README.md)

## 📝 Version Info

- **Version**: 1.0.0
- **Created**: 2025-12-27
- **Project**: PawSight Flutter Mobile App
- **Architecture**: MVVM with Provider

---

**Need Help?**

- Ask: "What commands are available?"
- Ask: "How do I create a feature?"
- Ask: "Show me the MVVM pattern"
- Or just describe what you want to build!
