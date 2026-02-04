# App Navigation Flow

## Visual Navigation Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP LAUNCH                               │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │   LoginScreen         │
                    │  - Email/Password     │
                    │  - Form Validation    │
                    └───────────┬───────────┘
                                │ Login Success
                                ▼
                    ┌───────────────────────┐
                    │   MainScreen          │
                    │  Bottom Navigation    │
                    └───────────┬───────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐       ┌──────────────┐      ┌────────────────┐
│  HomeScreen   │       │ CartScreen   │      │ ProfileScreen  │
│  Tab Index 0  │       │ Tab Index 2  │      │  Tab Index 3   │
└───────────────┘       └──────────────┘      └────────┬───────┘
                                                        │ Logout
        ┌───────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────┐
│ ProductListScreen     │  ◄──── MASTER VIEW
│  (Menu Tab)           │
│  Tab Index 1          │
│  - Search Products    │
│  - Filter Categories  │
│  - Product Cards      │
└───────────┬───────────┘
            │ Tap Product
            │ Navigator.push()
            ▼
┌───────────────────────┐
│ ProductDetailScreen   │  ◄──── DETAIL VIEW (NEW!)
│  - Product Image      │
│  - Full Description   │
│  - Quantity Selector  │
│  - Add to Cart Button │
└───────────┬───────────┘
            │ Back / Navigator.pop()
            ▼
        (Returns to ProductListScreen)
```

## Screen Hierarchy

```
main.dart
  └── GoldenDripApp (MaterialApp)
      └── CartProvider (State Management)
          └── MainScreen (Login Gate)
              ├── LoginScreen (if not logged in)
              └── Scaffold with BottomNavigationBar (if logged in)
                  ├── IndexedStack
                  │   ├── [0] HomeScreen
                  │   ├── [1] ProductListScreen ──► Navigator.push ──► ProductDetailScreen
                  │   ├── [2] CartScreen
                  │   └── [3] ProfileScreen
                  └── NavigationBar (Bottom Nav)
```

## Navigation Methods

### Bottom Navigation (Tab Switching)
```dart
// Handled by MainScreen state
void _onTabTapped(int index) {
  setState(() {
    _currentIndex = index;  // Switches IndexedStack index
  });
}
```

### Master to Detail (Product List → Detail)
```dart
// In ProductListScreen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(
      product: product,  // Pass product data
    ),
  ),
);
```

### Detail to Master (Product Detail → List)
```dart
// Automatic back button in AppBar
// Or programmatic:
Navigator.pop(context);
```

### Logout Flow
```dart
// In ProfileScreen
onLogout: () {
  setState(() {
    _isLoggedIn = false;  // Triggers MainScreen rebuild → LoginScreen
  });
}
```

## User Journey Examples

### Journey 1: Browse and Purchase
```
1. Launch App
2. LoginScreen → Enter credentials → Login
3. MainScreen loads → HomeScreen (Tab 0)
4. Tap "Menu" tab → ProductListScreen (Tab 1)
5. Select category "Hot Coffee"
6. Tap "Golden Latte" card
7. ProductDetailScreen opens (Navigator.push)
8. Adjust quantity to 2
9. Tap "Add to Cart"
10. See snackbar confirmation
11. Tap back button
12. Back to ProductListScreen
13. Cart badge shows "2"
14. Tap "Cart" tab → CartScreen (Tab 2)
15. Review order
16. Tap "Place Order"
17. Confirm dialog
18. Cart cleared, success message
```

### Journey 2: Search and View Details
```
1. MainScreen → ProductListScreen (Tab 1)
2. Tap search field
3. Type "mocha"
4. List filters to show Mocha items
5. Tap "Iced Mocha" card
6. ProductDetailScreen shows full details
7. View prep time, description, price
8. Decide not to purchase
9. Tap back button
10. Return to filtered list
11. Clear search to see all items
```

### Journey 3: Profile Management
```
1. MainScreen → ProfileScreen (Tab 3)
2. View personal information
3. Tap settings items (demo only)
4. Scroll to logout section
5. Tap "Logout"
6. Confirm dialog
7. Return to LoginScreen
```

## State Flow

### Cart State Updates
```
User Action → CartProvider.method() → notifyListeners()
    ↓
Consumer<CartProvider> rebuilds
    ↓
UI updates (cart badge, cart screen, totals)
```

### Navigation State
```
Bottom Nav Tap → _onTabTapped(index) → setState()
    ↓
_currentIndex changes
    ↓
IndexedStack shows selected screen
```

### Master/Detail State
```
ProductListScreen
    ↓
User taps product
    ↓
Navigator.push(ProductDetailScreen(product: selectedProduct))
    ↓
New route added to navigation stack
    ↓
ProductDetailScreen builds with product data
    ↓
User adds to cart → CartProvider updates
    ↓
Navigator.pop() or back button
    ↓
Return to ProductListScreen (cart badge updated)
```

## Data Flow: Adding to Cart

```
ProductDetailScreen
    │
    ├─► User adjusts quantity (local state)
    │
    ├─► User taps "Add to Cart"
    │
    ├─► Loop: for (i in 0..quantity)
    │       └─► cartProvider.addToCart(product)
    │
    ├─► CartProvider updates _items list
    │
    ├─► CartProvider.notifyListeners()
    │
    ├─► All Consumer<CartProvider> widgets rebuild:
    │       ├─► Cart badge in NavigationBar
    │       ├─► CartScreen items list
    │       └─► Order summary
    │
    └─► Show SnackBar confirmation
```

## Navigation Stack Examples

### Initial State (Bottom Nav)
```
Stack: [MainScreen]
Current: HomeScreen (Tab 0)
```

### After Opening Product Detail
```
Stack: [MainScreen] → [ProductDetailScreen]
Current: ProductDetailScreen
```

### After Returning to List
```
Stack: [MainScreen]
Current: ProductListScreen (Tab 1)
```

### Multiple Detail Views (if user navigates quickly)
```
Stack: [MainScreen] → [ProductDetailScreen(Latte)] → [ProductDetailScreen(Mocha)]
Current: ProductDetailScreen(Mocha)
```

## Route Names (Conceptual)

While this app uses direct navigation, here are conceptual route names:

```
/               → MainScreen (with login gate)
/login          → LoginScreen
/home           → HomeScreen (Tab 0)
/menu           → ProductListScreen (Tab 1)
/menu/:id       → ProductDetailScreen (pushed route)
/cart           → CartScreen (Tab 2)
/profile        → ProfileScreen (Tab 3)
```

## Deep Link Possibilities (Future Enhancement)

```
myapp://home           → Open app to HomeScreen
myapp://menu           → Open app to ProductListScreen
myapp://menu/1         → Open specific product detail
myapp://cart           → Open cart directly
myapp://profile        → Open profile
```

## Back Button Behavior

| Screen | Back Button Action |
|--------|-------------------|
| LoginScreen | Exit app |
| MainScreen (any tab) | Exit app |
| ProductDetailScreen | Pop to ProductListScreen |

## State Preservation

- **Bottom Navigation**: Uses `IndexedStack` - all tabs stay in memory
- **Product Detail**: Recreated on each navigation (stateless product data)
- **Cart**: Persists across all screens via CartProvider
- **Login State**: Stored in MainScreen state (cleared on logout)

## Performance Considerations

1. **IndexedStack**: Keeps all bottom nav screens in memory for instant switching
2. **ListView.builder**: Only builds visible items in product list
3. **Provider**: Only rebuilds widgets that listen to CartProvider
4. **Const Constructors**: Product data is const for efficiency

## Future Navigation Enhancements

- [ ] Named routes with route generator
- [ ] Deep linking support
- [ ] Route guards for authentication
- [ ] Persistent navigation state
- [ ] Transition animations between screens
- [ ] Bottom sheet for quick add to cart
- [ ] Modal for product preview
