# Mamosis AI-Powered Mammogram Screening

A medical imaging assistant tailored for doctors to manage patients and perform preliminary mammogram screenings using Google's Gemini 1.5 Flash AI model.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter) 
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart) 
![Firebase](https://img.shields.io/badge/Firebase-Core-FFCA28?logo=firebase) 
![AI](https://img.shields.io/badge/AI-Gemini_1.5-8E44AD)

## Key Features

*   **Doctor Portal**: Since there is no registration or registration process, you can log in with the 3 doctor numbers registered in Firebase.
*   **AI Analysis**: Integration with **Google Gemini 1.5 Flash** to analyze mammogram images for anormalities (Positive/Negative classification with risk descriptions). But it work fallback mode. If you want use, you can add your API key in `api_config.dart` file.
*   **Smart Scanning**: Support for both Camera and Gallery image sources.
*   **Dashboard**: Real-time statistics of patient screenings (Positive/Negative counts).
*   **Pro Features**: Subscription simulation with 'Pro' badge in UI and restricted features.

## Technical Architecture

This project follows **Clean Architecture** principles to ensure scalability, testability, and separation of concerns.

### Layered Structure
*   **Presentation Layer**: Contains UI (Widgets, Screens) and State Management (Flutter BLoC/Cubit).
*   **Domain Layer**: Pure Dart code containing Entities, Use Case definitions, and Repository interfaces.
*   **Data Layer**: Implementations of repositories, Datasources (Firestore, Firebase Storage), and Models with JSON serialization.

### Tech Stack & Packages
*   **State Management**: `flutter_bloc`, `equatable`
*   **Dependency Injection**: `get_it`
*   **Backend**: `cloud_firestore`, `firebase_auth`, `firebase_storage`
*   **AI**: `google_generative_ai`
*   **Utils**: `image_picker`, `shared_preferences`, `google_fonts`


## Screenshots

| Login Screen | Dashboard | Analysis Result |
|:---:|:---:|:---:|
| ![Login](/docs/Mamosis_Login.jpeg) | ![Home](/docs/Mamosis_Anasayfa.jpeg ) | ![Result](/docs/Mamosis_Patient_Details.jpeg) |

## Author

Developed by **[İbrahim Coşkun](https://github.com/ibrahimcoskun147)**
