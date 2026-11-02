# CatalogPro – Flutter Product Catalogue App

A cross-platform product catalogue application developed using Flutter for Android and iOS as part of the Analytix Flutter Developer Technical Assignment.

CatalogPro allows users to authenticate, browse products, search products, view product details, manage favourites, and scan QR codes to open specific products. The application also supports offline access and English/Arabic localization with RTL layout.

## Features

### 1. Authentication
- **DummyJSON Integration**: Real authentication using the `/auth/login` endpoint.
- **Secure Token**: Login tokens are stored in Keychain (iOS) or Keystore (Android) using `flutter_secure_storage`.
- **Persistence**: User session is maintained across app restarts.
- **Logout**: Confirmation dialog with UI polish and session clearing.

### 2. Product Catalogue
- **Grid Layout**: 2-column ecommerce-style grid with image thumbnails, titles, prices, and ratings.
- **Pagination**: Loads 20 products at a time (infinite scroll).
- **Pull-to-Refresh**: Updates the product list and local cache.
- **Search**: Debounced search (500ms) calling the API only after typing stops.
- **Shimmer Effects**: Smooth loading experience for both grid items and images.

### 3. Product Details
- **Image PageView**: Horizontal slider for multiple product images with shimmer placeholders.
- **Safe Brand Handling**: The brand field is hidden if null or empty to prevent crashes or blank labels.
- **Category & Rating**: Visual badges for category and star ratings.

### 4. Favourites
- **Local Persistence**: Favourites are saved in a local SQLite database (`sqflite`).
- **Persistence**: Favourites remain available even after the app is closed.
- **Grid UI**: Dedicated tab showing favourited products in a grid.

### 5. QR Code Scanner
- **QR Focus UI**: Custom scanner overlay with a focus square and semi-transparent background.
- **Deep Linking**: Opens products automatically using `catalogue://product/{id}`.
- **Simulator Support**: Manual URI entry field (pre-filled for convenience).
- **Error Handling**: Specific SnackBars for "Product not found" vs "Invalid QR format".

### 6. Offline Support
- **Local Caching**: The first page of products is cached in SQLite.
- **Offline Banner**: "You are offline" indicator appears at the top when no connection is detected.
- **No Blank Screens**: Last-loaded products are displayed when offline.

### 7. Localization (Arabic Support)
- **Full Translation**: All labels, messages, and error strings are localized.
- **RTL Support**: Layout direction and alignment flip automatically when switching to Arabic.
- **Dynamic Toggle**: Instantly switch languages in the Settings tab.

## Technology Stack

| Library | Purpose |
|---|---|
| `flutter_bloc` | State management (Auth, Products, Favourites) |
| `dio` | Network calls to DummyJSON API |
| `sqflite` | Local database for caching and favourites |
| `flutter_secure_storage` | Storing authentication tokens securely |
| `get_it` | Dependency injection (Service Locator) |
| `mobile_scanner` | QR code scanning functionality |
| `shimmer` | Loading placeholders for grid and images |
| `connectivity_plus` | Detecting network status for offline mode |

## Architecture

The application follows the **BLoC (Business Logic Component)** pattern with a clean directory structure:

- **Models**: Plain Dart classes for data parsing (User, Product).
- **Views**: UI screens and navigation logic.
- **Controllers (BLoC)**: Handles events, logic, and state transitions.
- **Core**: Contains networking (Dio), storage (SQLite), DI (GetIt), and Localization.
- **Widgets**: Reusable UI components like `ProductCard`.

## Project Structure

```text
lib/
├── controllers/      # BLoCs and Cubits
├── core/             # API, DB, DI, Localization, Constants
├── models/           # Data models (JSON parsing)
├── views/            # Screens (Auth, Products, Scanner, etc.)
├── widgets/          # Reusable UI components
└── main.dart         # App entry point and initialization
```

## Test Login Credentials

| Username | Password |
|---|---|
| `emilys` | `emilyspass` |

## Getting Started

1. **Install Dependencies**: `flutter pub get`
2. **Run the App**: `flutter run`

## Assignment Logic Tests
The project includes unit tests for:
- `ProductModel`: JSON parsing validation.
- `SettingsCubit`: Locale state transition logic.

To run tests: `flutter test`
