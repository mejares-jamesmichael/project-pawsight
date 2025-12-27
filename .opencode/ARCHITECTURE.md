# PawSight .opencode Architecture

Complete architecture documentation for the AI-powered development system.

## System Overview

The `.opencode` system provides intelligent development assistance for PawSight through:
- **Hierarchical agent orchestration** (1 orchestrator + 4 specialists)
- **Context-aware routing** (3-level context allocation)
- **Project-based session tracking**
- **Custom slash commands** for common operations

## Architecture Diagram

```
User Request
     ↓
Flutter Feature Orchestrator
     ↓
┌────┴────┬────────┬──────────┬─────────┐
↓         ↓        ↓          ↓         ↓
Feature   API      Code       Test      Direct
Builder   Specialist Reviewer  Generator Execution
     ↓         ↓        ↓          ↓
Context   Context  Context    Context
Bundle    Bundle   Bundle     Bundle
```

## Agent Hierarchy

### Level 1: Main Orchestrator

**flutter-feature-orchestrator** (`.opencode/agent/flutter-feature-orchestrator.md`)
- **Role**: Primary entry point, request analyzer, workflow coordinator
- **Responsibilities**:
  - Parse and classify requests
  - Route to appropriate specialists
  - Manage multi-agent workflows
  - Coordinate context allocation
  - Track project sessions
- **Routing Logic**:
  - Complexity assessment (simple/moderate/complex)
  - Keyword detection
  - Command routing
  - Multi-agent coordination

### Level 2: Specialized Agents

#### 1. Feature Builder
**Location**: `.opencode/agent/subagents/feature-builder.md`
- **Specialty**: Complete feature implementation with MVVM
- **Capabilities**:
  - Scaffold features (screen + provider + model + service)
  - Generate MVVM-compliant code
  - Set up navigation
  - Register providers
- **Commands**: `/build-feature`, `/create-screen`, `/add-model`
- **Context**: MVVM architecture, Provider patterns, templates

#### 2. API Integration Specialist
**Location**: `.opencode/agent/subagents/api-integration-specialist.md`
- **Specialty**: External API integration
- **Capabilities**:
  - HTTP service implementation
  - Response model generation
  - Error handling and timeouts
  - Authentication support
  - Multipart requests (n8n)
- **Commands**: `/add-api`
- **Context**: API integration process, error handling, HTTP templates

#### 3. Code Reviewer
**Location**: `.opencode/agent/subagents/code-reviewer.md`
- **Specialty**: Quality assurance and standards compliance
- **Capabilities**:
  - MVVM pattern validation
  - Provider correctness checks
  - Code style enforcement
  - Anti-pattern detection
  - Performance issue identification
- **Commands**: `/review-code`
- **Context**: Code style guide, MVVM architecture, review checklist

#### 4. Test Generator
**Location**: `.opencode/agent/subagents/test-generator.md`
- **Specialty**: Test coverage
- **Capabilities**:
  - Unit test generation (models, providers, services)
  - Widget test creation (screens)
  - Integration test scaffolding
  - Mock creation
  - Test fixture setup
- **Context**: Flutter patterns, code style, testing best practices

## Context Organization

### 4-Tier Context Structure

```
.opencode/context/
├── domain/          # Technical knowledge
├── processes/       # Workflow procedures
├── standards/       # Quality criteria
└── templates/       # Code boilerplate
```

### Context Files

#### Domain Knowledge (4 files)
1. **flutter-patterns.md**: Flutter/Dart best practices, widget patterns, async handling
2. **mvvm-architecture.md**: MVVM implementation guide, separation of concerns
3. **provider-state-management.md**: Provider patterns, state management rules
4. **sqlite-integration.md**: Database patterns, migrations (placeholder for future)

#### Process Knowledge (3 files)
1. **feature-development-workflow.md**: Complete feature implementation workflow
2. **api-integration-process.md**: API integration checklist (placeholder)
3. **code-review-checklist.md**: Quality assurance steps (placeholder)

#### Standards (3 files)
1. **code-style-guide.md**: Naming, formatting, conventions from AGENTS.md
2. **error-handling-standards.md**: Error patterns, user messaging, retry logic
3. **file-organization.md**: Project structure rules (placeholder)

#### Templates (4 files)
1. **screen-template.md**: MVVM screen boilerplate with loading/error states
2. **provider-template.md**: ChangeNotifier ViewModel template
3. **model-template.md**: Model with SQLite/JSON serialization
4. **http-service-template.md**: API service patterns (placeholder)

## Context Allocation Strategy

### Level 1: Complete Isolation (80% of tasks)
**When**: Single specialist, clear requirements, standard patterns
**Context**: 3-5 task-specific files
**Example**: `/create-screen favorites`
- Loads: MVVM architecture, Provider patterns, Screen template

### Level 2: Filtered Context (15% of tasks)
**When**: Multi-agent coordination, moderate complexity
**Context**: 6-10 files (task context + workflows + examples)
**Example**: `/build-feature quiz-system`
- Loads: All templates, MVVM, Provider, feature workflow

### Level 3: Comprehensive (5% of tasks)
**When**: High complexity, new patterns, critical features
**Context**: 12+ files (everything)
**Example**: Implementing entirely new architectural pattern
- Loads: All context files, all workflows, all examples

## Command System

### 5 Custom Commands

| Command | Purpose | Routes To | Creates |
|---------|---------|-----------|---------|
| `/build-feature {name}` | Complete feature | Feature Builder | Screen + Provider + Model + Service |
| `/add-api {name} {url}` | API integration | API Specialist | Service + Models |
| `/create-screen {name}` | Single screen | Feature Builder | Screen + Provider |
| `/add-model {name} {fields}` | Data model | Feature Builder | Model class |
| `/review-code {path}` | Quality check | Code Reviewer | Review report |

### Command Routing

```
User: /build-feature quiz-system
  ↓
Orchestrator analyzes
  ↓
Routes to Feature Builder
  ↓
Context Bundle:
  - domain/mvvm-architecture.md
  - domain/provider-state-management.md
  - standards/code-style-guide.md
  - templates/screen-template.md
  - templates/provider-template.md
  - templates/model-template.md
  ↓
Feature Builder executes
  ↓
Creates files, registers provider
  ↓
Returns to Orchestrator
  ↓
Orchestrator validates and reports to user
```

## Workflow Execution

### Standard Feature Development Flow

1. **Analyze** (Orchestrator)
   - Parse request
   - Determine complexity
   - Identify required specialists

2. **Route** (Orchestrator)
   - Select specialist(s)
   - Prepare context bundle
   - Create/update session

3. **Execute** (Specialist)
   - Load context
   - Implement feature
   - Follow patterns and standards

4. **Validate** (Orchestrator)
   - Check quality
   - Verify standards compliance
   - Run flutter analyze (if applicable)

5. **Report** (Orchestrator)
   - Summarize changes
   - List files created/modified
   - Provide next steps

## Session Management

### Project-Based Tracking

**Location**: `.opencode/sessions/{feature-name}-session.md`

**Structure**:
```markdown
# Feature Name Session

**Started**: 2025-12-27
**Status**: in_progress | completed | blocked

## Objective
Feature description

## Progress
- [x] Done
- [ ] Todo

## Files Modified
- lib/screens/...

## Decisions
- Decision: Rationale

## Next Steps
- Actions
```

**Lifecycle**:
- **Created**: When starting multi-step feature
- **Updated**: After each agent completes work
- **Closed**: When feature complete or abandoned

## Quality Gates

### Pre-Delegation
- Requirements clear
- Context bundle complete
- Specialist has necessary capabilities

### Post-Completion
- Code follows standards
- flutter analyze passes
- Tests exist and pass (if applicable)
- Documentation updated

## Integration Points

### With Existing Project

The system integrates with PawSight by:
1. **Reading** existing code patterns (lib/models, lib/providers, etc.)
2. **Following** established conventions (AGENTS.md)
3. **Generating** code that matches existing style
4. **Registering** new providers in main.dart
5. **Respecting** project structure

### With Development Workflow

```
Develop → Test → Review → Commit
   ↑        ↑       ↑
   |        |       |
Feature   Test    Code
Builder   Gen     Reviewer
```

## Performance Characteristics

- **Agent Selection**: < 1s (keyword + pattern matching)
- **Context Loading**: 3-5 files (Level 1), 6-10 files (Level 2)
- **Code Generation**: 2-5s per component
- **Quality Review**: 3-5s per file

## Extensibility

### Adding New Agents

1. Create agent file in `.opencode/agent/subagents/`
2. Define capabilities and routing triggers
3. Add routing logic to orchestrator
4. Create context bundle specification

### Adding New Commands

1. Create command file in `.opencode/command/`
2. Define syntax and examples
3. Add routing rule to orchestrator
4. Document in README

### Adding Context Files

1. Add file to appropriate directory (domain/processes/standards/templates)
2. Reference from relevant agents
3. Include in context bundles

## Design Principles

1. **Modular**: Small, focused files (50-200 lines each)
2. **Hierarchical**: Clear orchestrator → specialist pattern
3. **Context-Efficient**: Minimal context per task (80% Level 1)
4. **Standard-Driven**: Enforce PawSight patterns consistently
5. **Session-Aware**: Track ongoing work across interactions
6. **Quality-First**: Built-in review and validation

## Technology Stack

- **Language**: Markdown (XML-optimized agent definitions)
- **State Management**: Session files
- **Context System**: File-based knowledge organization
- **Routing**: Pattern matching + keyword detection
- **Integration**: Flutter/Dart project structure

---

**Version**: 1.0.0
**Created**: 2025-12-27
**Project**: PawSight Flutter Mobile App
