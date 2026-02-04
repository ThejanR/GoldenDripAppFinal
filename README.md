# Flutter Golden Drip Coffee App

A complete Flutter conversion of the Golden Drip Coffee Android app, originally built with Kotlin and Jetpack Compose.

## Features

### Master/Detail Pattern
- **Product List Screen (Master)**: Browse all coffee products with categories and search functionality
- **Product Detail Screen (Detail)**: Tap any product to view full details, adjust quantity, and add to cart

### Core Functionality
- **Home Screen**: Welcome section with popular products showcase
- **Menu/Product List**: Categorized product browsing with search and filter
- **Product Details**: Detailed product view with quantity selector and add to cart
- **Shopping Cart**: Full cart management with quantity adjustments
- **User Profile**: Profile information and settings
- **Authentication**: Login screen with form validation

### Technical Features
- ✅ Material Design 3 with custom theming
- ✅ State management using Provider
- ✅ Null-safety throughout
- ✅ Responsive UI with proper navigation
- ✅ Cart badge showing item count
- ✅ Smooth animations and transitions

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── models/
│   ├── product.dart                    # Product model & data source
│   └── cart_item.dart                  # Cart item model
├── providers/
│   └── cart_provider.dart              # Cart state management
├── screens/
│   ├── main_screen.dart                # Main navigation container
│   ├── home_screen.dart                # Home/welcome screen
│   ├── product_list_screen.dart        # Product list (Master view)
│   ├── product_detail_screen.dart      # Product details (Detail view)
│   ├── cart_screen.dart                # Shopping cart
│   ├── login_screen.dart               # Authentication
│   └── profile_screen.dart             # User profile
└── utils/
    └── theme.dart                      # App theme configuration
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Navigate to the project directory:
```bash
cd flutter_golden_drip
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Master/Detail Implementation

### Navigation Flow
1. User opens the Menu tab (Product List Screen)
2. Products are displayed in a scrollable list with categories
3. User taps on a product card
4. Navigates to Product Detail Screen using `Navigator.push()`
5. Product data is passed through constructor parameters
6. User can adjust quantity and add to cart
7. Returns to list with `Navigator.pop()`

### Code Example
```dart
// In ProductListScreen - Master View
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(
      product: product,
    ),
  ),
);

// ProductDetailScreen receives product data
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  
  const ProductDetailScreen({required this.product});
}
```

## Key Differences from Kotlin Version

### Navigation
- **Kotlin**: Jetpack Compose Navigation with `NavHost` and `composable()`
- **Flutter**: `Navigator` with `MaterialPageRoute` and bottom `NavigationBar`

### State Management
- **Kotlin**: ViewModel with StateFlow
- **Flutter**: Provider with ChangeNotifier

### UI Building
- **Kotlin**: Composable functions with `@Composable` annotation
- **Flutter**: Widget classes extending `StatelessWidget` or `StatefulWidget`

### Theming
- **Kotlin**: Material3 theme with `GoldenDripAppTheme`
- **Flutter**: `ThemeData` with Material 3 color schemes

## Running on Different Platforms

### Android
```bash
flutter run -d android
```

### iOS (macOS only)
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

## Features Implemented

- [x] Product listing with categories
- [x] Product search functionality
- [x] Master/Detail navigation pattern
- [x] Product detail page with quantity selector
- [x] Shopping cart with add/remove items
- [x] Cart item quantity management
- [x] Order summary with tax and fees
- [x] Login authentication
- [x] User profile screen
- [x] Bottom navigation with cart badge
- [x] Material Design 3 theming
- [x] Dark mode support

## Notes

- Product images use placeholder icons (Icons.coffee) - replace with actual assets
- Login is simplified for demo purposes - implement real authentication as needed
- Add actual product images to `assets/images/` and update `pubspec.yaml`

## License

This is a conversion project for educational/demonstration purposes.
