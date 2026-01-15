## 1.2.0 (2026-01-15) - FINAL CAT RELEASE 🐱✨

### 🎉 Major Improvements
*   **UI Consistency**: Standardized spacing and border radii across entire app using `AppSpacing` and `AppRadius` constants
*   **Chat Experience**: Major bug fixes and improvements to AI chat interface

### 🐛 Critical Bug Fixes
*   **Chat Input Crash**: Fixed "No Material widget found" error that caused app crash when using chat input
*   **Keyboard Overflow**: Fixed "BOTTOM OVERFLOWED BY 22 PIXELS" error when opening keyboard in empty chat
*   **Daily Purr-spective**: Resolved setState during build crash on home screen

### ✨ New Features
*   Added semantic mood color system (`AppColors.moodHappy`, `moodRelaxed`, `moodFearful`, `moodAggressive`, `moodMixed`)
*   Implemented standardized spacing constants (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32)
*   Implemented standardized radius constants (xs=4, sm=8, md=12, lg=16, xl=20, full=100)

### 💅 UI/UX Enhancements
*   Converted Library "Clear Filters" from pushing header bar to floating pill button for better UX
*   Improved Daily Purr-spective font size consistency
*   Enhanced Vet Hotline card spacing and text line height
*   Simplified ChatScreen by removing duplicate input bar implementation
*   Made ChatEmptyState scrollable to prevent overflow

### 📝 Documentation
*   Reorganized markdown files into `/docs` folder
*   Updated README with comprehensive project information

### 🔧 Technical Improvements
*   Refactored `chat_widgets.dart` with consistent spacing
*   Refactored `discover_screen.dart` with consistent spacing
*   Refactored `behavior_detail_screen.dart` with consistent spacing
*   All files pass `flutter analyze` with no issues

---

## 1.0.0 (2026-01-15) - THE CAT UPDATE

### New Features
*   **Splash Screen**: Comprehensive splash screens for all platforms with theme support
*   **AI Chat**: Fully functional AI assistant with AI Microservice backend, context awareness, and rate limiting
*   **Library**: Complete behavior library with 44+ behaviors, categories, moods, and search
*   **Hotline**: Refactored vet hotline with emergency vs general clinics, social media links, and modal contact options

### Enhancements
*   **UI/UX Polish**: 
    *   Improved spacing in library widgets
    *   Enhanced behavior detail screen with image carousel and "Ask AI" integration
    *   Better visual hierarchy and empty states
*   **Performance**:
    *   Optimized image loading
    *   Better list scrolling behavior
*   **Infrastructure**:
    *   Real environment variable support (`.env`) with CI secrets
    *   Updated dependencies (connectivity_plus, share_plus, etc.)

### Fixes
*   Fixed AI chat authentication and connection issues
*   Fixed asset loading in CI pipelines
*   Resolved gitleaks false positives

---

## 0.2.0-alpha (2025-11-30)

### Added
*   HomeScreen with bottom navigation (Home, Library, Hotline tabs)
*   Daily tip card with rotating cat behavior tips
*   Navigation cards for Library, AI Chat, and Vet Hotline
*   Forui UI framework integration with Zinc theme
*   Placeholder screens for Library and Hotline
*   About dialog with app version info

### Changed
*   Upgraded from "Hello World" to functional home interface
*   App now uses Provider for state management

---

## 0.1.0-alpha (2025-11-30)

### Added
*   Initial project structure with MVVM architecture
*   Data layer: SQLite database with `Behavior` model
*   `DatabaseHelper` service with singleton pattern
*   `LibraryProvider` for state management (search, filter)
*   Seeded 15 cat behaviors for offline library
*   CI/CD pipelines (GitHub Actions)
*   Gitleaks secret scanning integration

### Notes
*   This is an early alpha release for testing purposes
*   Core UI features are not yet implemented
*   App displays "Hello World" placeholder screen
