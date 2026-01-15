# PawSight 🐾

> Your pocket companion for understanding and caring for your feline friends.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State%20Management-blueviolet?style=for-the-badge)

PawSight is a comprehensive mobile application designed to bridge the communication gap between cats and their owners. By leveraging an extensive offline library of behavioral cues and an advanced AI assistant, PawSight empowers users to interpret their pet's mood, needs, and health signals with confidence.

## 📖 About

### 🎯 Problem Statement
Cat owners often struggle to understand their feline companions' body language and behaviors, leading to miscommunication and potential health issues. Without proper interpretation, owners may miss important signals indicating stress, illness, or discomfort in their pets.

### ✨ Our Solution
PawSight provides cat owners with an intuitive mobile application that combines an extensive offline behavior library with AI-powered assistance. The app helps users decode their cat's body language, offers quick access to veterinary resources, and delivers daily insights to strengthen the human-cat bond.

## 🚀 Key Features

*   **📚 Extensive Behavior Library:** An offline-accessible encyclopedia of cat body language, categorized by mood (Happy, Fearful, Aggressive) and body part (Tail, Ears, Eyes).
*   **🤖 AI Assistant:** An intelligent chatbot powered by external AI services to answer specific questions about your cat's behavior and well-being.
*   **🏥 Vet Hotline:** A quick-access directory for emergency and general veterinary clinics, ensuring help is always at your fingertips.
*   **💡 Daily Purr-spective:** Daily fun facts and tips to keep you engaged and learning about your furry companion.

## 🛠️ Tech Stack

### Frontend
*   **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.9.2)
*   **Language:** [Dart](https://dart.dev/)
*   **State Management:** [Provider](https://pub.dev/packages/provider)
*   **UI Components:** [Forui](https://pub.dev/packages/forui)
*   **Icons:** [Font Awesome](https://pub.dev/packages/font_awesome_flutter)

### Backend & Storage
*   **Local Database:** [SQLite](https://pub.dev/packages/sqflite)
*   **AI Integration:** External AI microservice integration
*   **Architecture:** MVVM pattern with clean code principles

### Development & Tools
*   **Code Style:** Dart formatter and analyzer
*   **Testing:** Flutter test framework
*   **Platform Support:** Android (iOS coming soon)

## 🌐 Live Demo

PawSight is currently available for Android. You can download the latest version from our [Releases](https://github.com/mejares-jamesmichael/project-pawsight/releases) page.

### Test Accounts
No account creation is required. The app works immediately upon installation with all features accessible without registration.

## 📦 Project Structure

```
pawsight/
├── lib/
│   ├── models/          # Data models with SQLite mapping
│   ├── services/        # Database and API services (Singleton)
│   ├── providers/       # ChangeNotifier ViewModels
│   └── widgets/         # Reusable UI components
├── test/                # Unit and widget tests
├── docs/                # Documentation and user manual
└── assets/              # Images and other resources
```

## 📚 Documentation

### Core Documentation
*   [User Manual](docs/USER-MANUAL.md) - Complete guide to using PawSight
*   [Agent Guidelines](AGENTS.md) - Development guidelines and architecture overview

### AI & Chatbot Documentation
*   [GEMINI.md](GEMINI.md) - AI integration details and capabilities

### Testing & Quality
*   Run all tests: `cd pawsight && flutter test`
*   Run single test: `flutter test test/database_test.dart`
*   Lint code: `flutter analyze`

### Development & Operations
*   Run app: `cd pawsight && flutter run`
*   Build Android: `flutter build apk`
*   Build iOS: `flutter build ios`
*   Format code: `dart format .`

## 🤖 AI-Powered Features

### PawSight AI Assistant - Your Feline Behavior Expert
The AI Assistant provides personalized insights and answers to your specific questions about cat behavior, health, and care.

#### Key Capabilities
*   Behavior interpretation and analysis
*   Health and wellness advice
*   Training and behavioral modification tips
*   Nutritional guidance
*   Emergency response protocols

#### Examples
*   "Why does my cat knead me with her paws?"
*   "What should I do if my cat is suddenly hiding all the time?"
*   "Is it normal for my cat to sleep so much?"
*   "How can I help my cat adjust to a new home?"

#### Technical Architecture
*   External AI microservice integration
*   Secure API communication
*   Local chat history storage
*   Offline detection and user notifications

## 📊 CI/CD Pipeline

### Quality Gates
* Automated testing on every commit
* Code linting and formatting checks
* Performance benchmarking
* Security vulnerability scanning

## 📝 Project Management

*   Agile development methodology
*   Regular sprint planning and retrospectives
*   Comprehensive documentation
* Version control with Git

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

Made with ❤️ by James Michael for cat lovers everywhere.
