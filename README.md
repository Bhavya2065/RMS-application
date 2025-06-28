# 🍽️ RMS Application - Restaurant Table & Food Booking

Welcome to the **RMS Application**, a user-friendly mobile application designed to revolutionize the dining experience! With RMS, users can effortlessly book dining tables and pre-order food at their favorite restaurants, ensuring a seamless and delightful dining experience.

## 🎯 Project Goal
The RMS Application aims to simplify restaurant reservations and food ordering by allowing users to:
- Reserve dining tables in advance.
- Pre-order food to save time and enhance convenience.
- Enjoy a hassle-free dining experience with real-time updates.

## ✨ Features
- **Table Reservations**: Book a dining table for a specific date and time with ease.
- **Food Pre-Ordering**: Browse the menu and pre-order food to have it ready upon arrival.
- **User Authentication**: Secure login and registration using Firebase Authentication.
- **Real-Time Database**: Powered by Firebase Firestore for fast and reliable data management.
- **Intuitive UI**: A sleek and responsive interface built with Flutter for a smooth user experience.
- **Cross-Platform Support**: Available on Android (iOS support planned for future releases).

## 🛠️ Technologies Used
### Frontend
- **Flutter**: Cross-platform framework for building a beautiful and responsive UI.
- **Dart**: Programming language for Flutter, ensuring fast and efficient development.
- **Groovy**: Used for Gradle build scripts in Android Studio.

### Backend
- **Firebase Firestore**: Cloud-based NoSQL database for real-time data storage and synchronization.
- **Firebase Authentication**: Secure user authentication with email, phone, or social logins.

## 📱 Screenshots
| Home | Menu | Cart |
|------|------|------|
| ![](UI_images/Home_page.png) | ![](UI_images/Menu.png) | ![](UI_images/Add_to_cart.png) |

| Booking | Confirmation |
|---------|--------------|
| ![](UI_images/table_booking.png) | ![](UI_images/order_confirmation.png) |

## 🚀 Getting Started
Follow these steps to set up and run the RMS Application locally.

### Prerequisites
- **Android Studio**: Latest version installed.
- **Flutter SDK**: Installed and configured (version 3.0.0 or higher recommended).
- **Firebase Account**: Set up a Firebase project for Firestore and Authentication.
- **Git**: For cloning the repository.

### Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/rms_application.git
   cd rms_application
   ```

2. **Install Dependencies**:
   Run the following command to install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. **Set Up Firebase**:
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Add an Android app to your Firebase project and download the `google-services.json` file.
   - Place the `google-services.json` file in the `android/app` directory.
   - Enable Firestore and Authentication (Email/Password or other providers) in the Firebase Console.

4. **Run the Application**:
   - Connect an Android device or emulator.
   - Run the app using:
     ```bash
     flutter run
     ```

## 📂 Project Structure
```
rms_application/
├── android/               # Android-specific files and configurations
├── ios/                   # iOS-specific files (for future iOS support)
├── lib/                   # Flutter source code (Dart files)
│   ├── models/            # Data models
│   │   ├── food_category.dart
│   │   └── product.dart
│   ├── about_us.dart
│   ├── add_to_cart.dart
│   ├── contact_us.dart
│   ├── favorite.dart
│   ├── firebase_options.dart
│   ├── forgot.dart
│   ├── home_page.dart
│   ├── main.dart
│   ├── menu.dart
│   ├── order_confirmation.dart
│   ├── order_page.dart
│   ├── product_detail.dart
│   ├── profile.dart
│   ├── see_all.dart
│   ├── settings.dart
│   ├── sign_in.dart
│   ├── sign_up.dart
│   ├── splash.dart
│   └── table_booking.dart
├── pubspec.yaml           # Flutter dependencies and configuration
└── README.md              # Project documentation
```

## 🤝 Contributing
We welcome contributions to enhance the RMS Application! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

## 📞 Contact
For questions or feedback, reach out to:
- **GitHub**: [Bhavya2065](https://github.com/Bhavya2065)

## 🌟 Acknowledgements
- [Flutter](https://flutter.dev/) for the amazing cross-platform framework.
- [Firebase](https://firebase.google.com/) for robust backend services.
- The open-source community for their invaluable contributions.

---

⭐ **Star this repository** if you find it helpful! Let's make dining easier and more enjoyable together! 🍴
