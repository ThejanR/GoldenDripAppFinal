# Kotlin to Flutter Conversion Guide

## Overview
This document explains how the Golden Drip Coffee app was converted from Kotlin/Jetpack Compose to Flutter/Dart.

## Architecture Comparison

### Kotlin (Original)
```
app/
├── data/
│   ├── CartItem.kt
│   ├── DataSource.kt (MenuItem model)
├── screen/
│   ├── HomeScreen.kt
│   ├── MenuScreen.kt
│   ├── CartScreen.kt
│   ├── ProfileScreen.kt
│   └── LoginScreen.kt
├── viewmodel/
│   ├── CartViewModel.kt
│   └── ProfileViewModel.kt
└── MainActivity.kt
```

### Flutter (Converted)
```
lib/
├── models/
│   ├── product.dart (MenuItem → Product)
│   └── cart_item.dart
├── providers/
│   └── cart_provider.dart (CartViewModel → CartProvider)
├── screens/
│   ├── home_screen.dart
│   ├── product_list_screen.dart (MenuScreen)
│   ├── product_detail_screen.dart (NEW - Detail view)
│   ├── cart_screen.dart
│   ├── profile_screen.dart
│   ├── login_screen.dart
│   └── main_screen.dart (MainActivity)
└── main.dart
```

## Key Conversions

### 1. Data Models

**Kotlin (MenuItem):**
```kotlin
data class MenuItem(
    val id: Int,
    val name: String,
    val price: String,
    val category: String,
    val image: Int
)
```

**Flutter (Product):**
```dart
class Product {
  final int id;
  final String name;
  final double price;  // Changed from String to double
  final String category;
  final String imageAsset;  // Changed to String for asset path
  
  const Product({...});
  
  String get priceFormatted => '\$${price.toStringAsFixed(2)}';
}
```

### 2. State Management

**Kotlin (ViewModel with StateFlow):**
```kotlin
class CartViewModel : ViewModel() {
    private val _cartState = MutableStateFlow(CartState())
    val cartState: StateFlow<CartState> = _cartState.asStateFlow()
    
    fun addToCart(menuItem: MenuItem) {
        viewModelScope.launch { ... }
    }
}
```

**Flutter (Provider with ChangeNotifier):**
```dart
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => List.unmodifiable(_items);
  
  void addToCart(Product product) {
    // Update items
    notifyListeners();  // Notify widgets to rebuild
  }
}
```

### 3. UI Components

**Kotlin (Composable Function):**
```kotlin
@Composable
fun MenuScreen(cartViewModel: CartViewModel = viewModel()) {
    val menuItems = MenuDataSource.getMenuItems()
    
    LazyColumn {
        items(menuItems) { item ->
            MenuItemCard(item = item)
        }
    }
}
```

**Flutter (StatelessWidget):**
```dart
class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    final products = ProductDataSource.getProducts();
    
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductListItem(product: products[index]);
      },
    );
  }
}
```

### 4. Navigation

**Kotlin (Compose Navigation):**
```kotlin
NavHost(navController = navController, startDestination = "home") {
    composable("home") { HomeScreen() }
    composable("menu") { MenuScreen() }
    composable("cart") { CartScreen() }
}
```

**Flutter (Navigator + Bottom Navigation):**
```dart
// Bottom Navigation
NavigationBar(
  selectedIndex: _currentIndex,
  onDestinationSelected: (index) => setState(() => _currentIndex = index),
  destinations: [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
    NavigationDestination(icon: Icon(Icons.cart), label: 'Cart'),
  ],
)

// Detail Navigation (NEW in Flutter version)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(product: product),
  ),
);
```

### 5. Theming

**Kotlin (Material3):**
```kotlin
@Composable
fun GoldenDripAppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(primary = ...),
        content = content
    )
}
```

**Flutter (ThemeData):**
```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFFD4A574),
    brightness: Brightness.light,
  ),
)
```

### 6. Consuming State

**Kotlin (collectAsState):**
```kotlin
@Composable
fun CartScreen(cartViewModel: CartViewModel) {
    val cartState by cartViewModel.cartState.collectAsState()
    
    Text("Total: ${cartState.total}")
}
```

**Flutter (Consumer):**
```dart
Consumer<CartProvider>(
  builder: (context, cartProvider, child) {
    return Text('Total: \$${cartProvider.total.toStringAsFixed(2)}');
  },
)
```

## Master/Detail Implementation

### What's New in Flutter Version

The Flutter version adds a **Product Detail Screen** that wasn't explicitly separate in the Kotlin version:

**Navigation Flow:**
1. ProductListScreen (Master) → Shows all products in a list
2. User taps a product card
3. Navigates to ProductDetailScreen (Detail) → Shows full product info
4. User can add items to cart with quantity selector
5. Returns to list

**Implementation:**
```dart
// In ProductListScreen
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  },
  child: ProductCard(...),
)

// ProductDetailScreen
class ProductDetailScreen extends StatefulWidget {
  final Product product;  // Passed via constructor
  
  const ProductDetailScreen({required this.product});
}
```

## Quick Reference Table

| Feature | Kotlin/Compose | Flutter/Dart |
|---------|---------------|--------------|
| State Management | ViewModel + StateFlow | Provider + ChangeNotifier |
| UI Building | @Composable functions | Widget classes |
| Lists | LazyColumn/LazyRow | ListView.builder/GridView |
| Navigation | NavHost + composable | Navigator.push/pop |
| State Collection | collectAsState() | Consumer widget |
| Layouts | Column, Row, Box | Column, Row, Stack |
| Styling | Modifier chains | Widget properties |
| Theming | MaterialTheme | ThemeData |
| Icons | Icons.Default.X | Icons.x |
| State Updates | StateFlow.emit() | notifyListeners() |

## Running the Flutter App

1. **Install Dependencies:**
   ```bash
   cd flutter_golden_drip
   flutter pub get
   ```

2. **Run on Android:**
   ```bash
   flutter run
   ```

3. **Run on iOS (macOS only):**
   ```bash
   flutter run -d ios
   ```

4. **Run on Web:**
   ```bash
   flutter run -d chrome
   ```

## Next Steps

1. **Add Real Images:** Replace Icon(Icons.coffee) with actual product images
2. **Implement Authentication:** Add real login/registration backend
3. **Add Animations:** Enhance transitions and micro-interactions
4. **Persist Data:** Add local storage for cart and user preferences
5. **API Integration:** Connect to a real backend service

## Common Gotchas

1. **Async Operations:** Use `Future` and `async/await` instead of `suspend` functions
2. **Null Safety:** Flutter uses `?` and `!` operators for nullable types
3. **Immutability:** Use `const` constructors where possible for performance
4. **BuildContext:** Always available in build methods, pass it when needed
5. **State Rebuilding:** Call `setState()` or `notifyListeners()` to trigger UI updates
