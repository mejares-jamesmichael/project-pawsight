# PawSight: Implementation Plan

## Phase 1: Project Initialization & Basic Offline Structure
- [x] Create a Flutter package named `pawsight` in the current directory.
    - Use `flutter create . --project-name pawsight` (simulated via create_project tool).
- [x] Remove default boilerplate (counter app code) and test files.
- [x] Update `pubspec.yaml`:
    - Set version to `0.1.0`.
    - Add dependencies: `sqflite`, `path`, `provider`, `http`, `url_launcher`, `font_awesome_flutter`, `image_picker` (for AI vision), `flutter_markdown` (for rendering AI text).
- [x] Update `README.md` with a short project description.
- [x] Create `CHANGELOG.md` initialized at `0.1.0`.
- [x] Commit initial setup to git branch `feat/initial-setup`.
- [x] Verify the app runs.

## Phase 2: Data Layer & Offline Library (SQLite)
- [ ] Create `assets/images` directory and add placeholder images.
- [ ] Update `pubspec.yaml` to include `assets/`.
- [ ] Implement `DatabaseHelper` class:
    - Initialize `sqflite`.
    - Create `behaviors` table.
    - Seed with Feline behavior data.
- [ ] Create `Behavior` model class.
- [ ] Implement `LibraryProvider` for fetching/filtering.
- [ ] **Unit Test:** Verify database seeding.
- [ ] Commit changes.

## Phase 3: UI Implementation - Offline Features
- [ ] Implement `HomeScreen`:
    - Navigation: Library, AI Assistant, Vet Hotline.
    - "Daily Tip" widget.
- [ ] Implement `LibraryScreen`:
    - Search bar & Filter chips.
    - `ListView` of behaviors.
- [ ] Implement `BehaviorDetailScreen`:
    - Hero image, description, advice.
- [ ] **Manual Verification:** Check navigation/search.
- [ ] Commit changes.

## Phase 4: AI Chat & Vision Feature (n8n Integration)
- [ ] Implement `ChatRepository`:
    - Function `sendMessage(String text, File? image)`:
        - Uses `MultipartRequest` to send text and optional image to n8n webhook.
- [ ] Implement `ChatProvider`:
    - Manage message list (User/AI).
    - Handle loading/error states.
- [ ] Implement `ChatScreen`:
    - Message bubbles (Markdown support).
    - Input field.
    - **Camera/Gallery Button:** Uses `image_picker` to select photo.
    - Image preview before sending.
- [ ] **Integration Test:** Mock n8n response with/without image.
- [ ] Commit changes.

## Phase 5: Vet Hotline (Static Resources)
- [ ] Create `VetClinic` model:
    - Fields: `name`, `phone`, `address`, `socialLink`.
- [ ] Implement `EmergencyRepository` with static list.
- [ ] Implement `HotlineScreen`:
    - List of clinics.
    - "Call" button (`url_launcher`).
    - Social media icon button (`font_awesome_flutter`).
    - Display address text.
- [ ] Commit changes.

## Phase 6: Polishing & Final Review
- [ ] Run `dart_fix` and `dart_format`.
- [ ] Run `analyze_files` and fix issues.
- [ ] Create `GEMINI.md` and comprehensive `README.md`.
- [ ] Perform final walkthrough.
- [ ] Present to user.

## Journal
- **Nov 30, 2025**: Project started. Phase 1 completed (Initialization, dependencies, git setup).