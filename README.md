# PawSight: Pet Behavior Guide

**PawSight** is a hybrid (online/offline) mobile application designed to help pet owners, specifically cat owners, interpret their pet's body language. It combines a robust offline library of behaviors with online AI-powered assistance (Text + Vision) and veterinary resources.

## Features

*   **Offline Behavior Library:** A comprehensive, searchable list of 15-20 common cat behaviors with descriptions and visual aids. All primary behavior data and images are bundled with the application, ensuring functionality without an internet connection.
*   **AI-Powered Assistant:** A chat interface that connects to an external n8n webhook to analyze user queries and uploaded photos using AI.
*   **Emergency Vet Hotline:** A static list of national/local vet hotlines for quick access to emergency resources.
*   **In-App Quizzes:** Simple multiple-choice quizzes to reinforce learning and test user knowledge.

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

## Getting Started

1.  **Navigate to the app directory:**
    ```bash
    cd pawsight
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

## Build Instructions

*   **Navigate to the app directory:**
    ```bash
    cd pawsight
    ```
*   **Run the appropriate build command:**
    *   **Android:**
        ```bash
        flutter build apk
        ```
    *   **iOS:**
        ```bash
        flutter build ios
        ```
