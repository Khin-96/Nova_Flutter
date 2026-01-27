# Nova Wear Mobile App

A premium, high-performance Flutter e-commerce application for Nova Wear. Designed with a minimalist Black & White aesthetic inspired by global brands like Nike and Adidas.

## Premium Features
- **Modern UI**: Minimalist design with bold typography and high-impact animations.
- **Cart Management**: Full shopping bag functionality with local persistence.
- **M-Pesa Checkout**: Integrated STK Push payment system via the Render backend.
- **Performance**: Cached images and shimmer loading effects for a smooth experience.
- **Discovery**: Dynamic category filtering and real-time product search.

## Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Persistence**: SharedPreferences
- **UI Packages**: 
  - `animate_do` (Animations)
  - `shimmer` (Loading states)
  - `cached_network_image` (Image optimization)
  - `google_fonts` (Outfit Font)
- **Backend**: Hosted on Render (Node.js/MongoDB)

---

## How to Run on Your Phone

### 1. Prerequisites
- Ensure you have **Flutter** installed on your computer (`flutter --version`).
- Enable **Developer Options** and **USB Debugging** on your phone:
  - Go to `Settings` -> `About Phone`.
  - Tap `Build Number` 7 times until you see "You are now a developer".
  - Go to `Settings` -> `System` (or `Additional Settings`) -> `Developer Options` -> Enable **USB Debugging**.

### 2. Connect Your Phone
- Plug your phone into your computer via a USB cable.
- A popup may appear on your phone asking to "Allow USB Debugging" – tap **Allow**.

### 3. Verify Connection
Run this in your terminal to see if your phone is detected:
```bash
flutter devices
```

### 4. Run the App
Navigate to the app directory and start the engine:
```bash
cd nova_wear_app
flutter run
```
*Note: If you have multiple devices connected, use `flutter run -d <DEVICE_ID>`.*

### Creating a Final App (APK)
To share the app with friends or install it permanently:
```bash
flutter build apk --release
```
The APK will be located in: `build/app/outputs/flutter-apk/app-release.apk`

---

## Architecture
- `lib/models/`: Data structures for Products and Cart.
- `lib/services/`: API communication (ApiService).
- `lib/providers/`: Global state management.
- `lib/screens/`: App pages (Home, Category, Product Details, Cart, etc.).
- `lib/widgets/`: Reusable UI components.

## API Configuration
The app is currently configured to point to:
`https://novawear.onrender.com`
To change this, update `baseUrl` in `lib/services/api_service.dart`.
