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
