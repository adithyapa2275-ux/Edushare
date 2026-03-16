# EduShare 📚

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)

**EduShare** is a comprehensive academic book marketplace and resource-sharing platform built with Flutter. It aims to make educational resources accessible and affordable by allowing students to buy, sell, and share academic books, study guides, and notes within their community.

## ✨ Key Features

*   **🛒 Dynamic Marketplace**: Browse, search, and discover a wide variety of academic materials categorized by subject and department. Enjoy a responsive grid/list view that adapts seamlessly across Web and Mobile.
*   **🤖 Smart "Recommended for You" Engine**: Context-aware book suggestions based on complex algorithms prioritizing identical categories, authors, title keywords, and price similarities.
*   **💾 Intelligent Cart & Wishlist**: Items added to your cart or favorites are saved locally on your device (Guest Mode). Upon logging in, local preferences are intelligently merged with your cloud data via Firebase Firestore.
*   **🛍️ Modern "Flipkart-style" UI/UX**:
    *   Beautiful **Trust Markers** (Quality Checked, Secure Payments, 7-Day Returns).
    *   Redesigned **My Orders** page featuring a flattened, per-item modern layout with status tracking and direct navigation to ordered items.
    *   Universal `BookImage` widget for robust image loading, error handling, and standard fallbacks.
*   **🌓 Adaptive Theming**: Symmetrical Light and Dark mode themes with high-contrast text rendering, easily switchable via the `ThemeProvider`.
*   **🔒 Secure Checkout**: Seamless checkout flow with multiple payment options (UPI, Card, Cash on Delivery) and strict 10-digit phone number validations.
*   **🔄 Sell & Donate**: Easily list your old books for sale or donate them for FREE to peers in need. The platform automatically adds "Verified" seller markers to trusted listings.
*   **👨‍💻 Admin Dashboard**: A dedicated portal allowing administrators to manage all book listings, view analytics, and oversee users and platform orders.

## 🛠 Tech Stack

### Frontend
*   **Framework**: [Flutter](https://flutter.dev/) (Web & Mobile)
*   **Language**: Dart
*   **State Management**: [Provider](https://pub.dev/packages/provider) (`CartProvider`, `FavoritesProvider`, `UserProvider`, `MarketplaceProvider`, `SellProvider`, `OrderProvider`, `AdminProvider`)
*   **Local Storage**: `shared_preferences`

### Backend & Cloud
*   **Database**: [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore) for real-time data sync and complex querying.
*   **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth) supporting email/password and role-based access control (Admin vs User).
*   **Storage**: [Firebase Storage](https://firebase.google.com/docs/storage) / Cloudinary for fast and reliable image hosting.

## 📦 Getting Started

### Prerequisites
*   Flutter SDK (`^3.10.0` or higher)
*   Dart SDK
*   A connected Firebase Project

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/edushare.git
    cd edushare
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase:**
    Ensure you have your Firebase configuration files set up for the platforms you are targeting:
    - **Web**: `firebase_options.dart` configured via FlutterFire CLI
    - **Android**: `google-services.json` placed in `android/app/`
    - **iOS**: `GoogleService-Info.plist` placed in `ios/Runner/`

4.  **Run the application:**
    ```bash
    # For Web
    flutter run -d chrome

    # For Mobile
    flutter run
    ```

## 📁 Project Structure

The codebase is structured under `lib/` following a feature-first and provider-based architecture:

*   `core/`: App-wide constants, Theme configurations, API clients, and text styles.
*   `models/`: Data classes mapped securely to Firestore documents (e.g., `Book`, `Order`, `UserModel`).
*   `providers/`: State management controllers handling the heavy lifting of business logic.
*   `widgets/`: Reusable UI components ensuring DRY principles (App bars, Book cards, Carousel banners, Trust Markers).
*   `admin/`: Specialized pages and components explicitly for administrative management.
*   `(root)`: Screen-level declarative routing (Home, Cart, Checkout, Profile, Book Details).

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License
This project is proprietary and confidential. Unauthorized copying of files, via any medium, is strictly prohibited.
