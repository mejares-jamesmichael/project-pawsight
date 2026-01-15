# PawSight 🐾

> Your pocket companion for understanding and caring for your feline friends.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State%20Management-blueviolet?style=for-the-badge)

PawSight is a smart mobile application designed to bridge the communication gap between cats and their owners. By leveraging an extensive offline library of behavioral cues and an advanced AI assistant, PawSight empowers users to interpret their pet's mood, needs, and health signals with confidence.

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

## 📲 Installation

PawSight is currently available for Android. You can download the latest version from [Releases](https://github.com/mejares-jamesmichael/project-pawsight/releases) page.

1. Go to the Releases page of this repository.
2. Download the latest .apk file (e.g., pawsight_v1.0.0.apk) from the "Assets" section.
3. Open the file on your Android device to install the application.
Note: You may need to enable "Install unknown apps" in your device settings.

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

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

Made with ❤️ by James Michael for cat lovers everywhere.
