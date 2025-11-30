# Project Context: PawSight

## Project Overview
**PawSight** is a mobile application designed to help pet owners (specifically cat owners initially) interpret their pet's body language. It functions as a hybrid application with two core modes:
1.  **Offline Field Guide:** A fast, locally stored library of cat behaviors (images + descriptions) stored in SQLite.
2.  **Online AI Assistant:** A chat interface that connects to an external **n8n webhook** to analyze user queries and uploaded photos using AI.

## Project Structure
*   **`pawsight/`**: The Flutter application source code.
*   **`DESIGN.md`**: detailed technical specifications, database schema, and API contracts.
*   **`IMPLEMENTATION.md`**: Phased checklist for building the application.
*   **`PawSight.md`**: Original concept and high-level objectives.

## Tech Stack
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider (MVVM Pattern)
*   **Local Database:** SQLite (via `sqflite` package)
*   **Networking:** `http` package (for n8n communication)
*   **Hardware:** Camera/Gallery access (via `image_picker`) for AI vision features.

## Architecture
The project follows a Model-View-ViewModel (MVVM) architecture:
*   **Model:** `Behavior`, `VetClinic`, `DatabaseHelper`, `ChatRepository`.
*   **ViewModel:** `LibraryProvider`, `ChatProvider`.
*   **View:** Flutter Widgets (Screens).

## Development Status
*   **Current Phase:** Phase 2 (Data Layer).
*   **Next Steps:** Implement `DatabaseHelper` and seed data.

## Build Instructions
*   **Navigate to App:** `cd pawsight`
*   **Run App:** `flutter run`
*   **Code Generation (if needed):** `dart run build_runner build`
*   **Linting:** `dart analyze`