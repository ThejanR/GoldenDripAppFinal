# Quick Start Guide

## 🚀 How to Run the Flutter App

### Prerequisites Check

Before running the app, ensure you have Flutter installed:

```bash
flutter doctor
```

You should see checkmarks (✓) for:
- Flutter SDK
- At least one platform (Android, iOS, Web, or Desktop)
- VS Code or Android Studio (optional but recommended)

### Step-by-Step Instructions

#### 1. Navigate to Project Directory
```bash
cd "c:\Users\Thejan\AndroidStudioProjects\GoldenDripApp - Copy\flutter_golden_drip"
```

#### 2. Get Dependencies
```bash
flutter pub get
```

Expected output:
```
Running "flutter pub get" in flutter_golden_drip...
Resolving dependencies...
+ provider 6.1.1
...
Got dependencies!
```

#### 3. Run the App

**Option A: Let Flutter Choose Device**
```bash
flutter run
```

**Option B: Specify Device**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Examples:
flutter run -d chrome              # Web browser
flutter run -d windows             # Windows desktop
flutter run -d emulator-5554       # Android emulator
```

#### 4. Expected Output

```
Launching lib\main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...
This app is linked to the debug service: ws://127.0.0.1:50000/...
Debug service listening on ws://127.0.0.1:50000/...

Running with sound null safety

🔥  To hot reload changes while running, press "r" or "R".
For a more detailed help message, press "h". To quit, press "q".

An Observatory debugger and profiler on Chrome is available at: ...
The Flutter DevTools debugger and profiler on Chrome is available at: ...
```

## 📱 Testing the App Features

### Test Scenario 1: Login Flow
1. **App launches** → You see LoginScreen
2. **Enter any email** (e.g., `test@example.com`)
3. **Enter any password** (minimum 6 characters)
4. **Tap "Login" button**
5. **Result**: Should navigate to MainScreen with HomeScreen visible

### Test Scenario 2: Browse Products (Master View)
1. **From HomeScreen**, tap "Menu" tab (second icon)
2. **You see**: ProductListScreen with all 13 products
3. **Try search**: Type "mocha" in search field
4. **Result**: List filters to show only Mocha items
5. **Clear search**: Delete text to see all products again
6. **Try categories**: Tap "Hot Coffee" chip
7. **Result**: List shows only hot coffee items
8. **Tap "All"**: See all products again

### Test Scenario 3: Product Detail (Detail View)
1. **From ProductListScreen**, tap any product card (e.g., "Golden Latte")
2. **You see**: ProductDetailScreen with full product info
3. **Observe**:
   - Product name and image
   - Category badge
   - "Popular" chip (if applicable)
   - Prep time
   - Full description
   - Current price
   - Quantity selector (default: 1)
4. **Tap "+" button**: Quantity increases to 2
5. **Observe**: Total price updates (price × quantity)
6. **Tap "Add to Cart" button**
7. **Result**: SnackBar appears confirming item added
8. **Check navigation bar**: Cart badge shows "2"
9. **Tap back button** or device back
10. **Result**: Return to ProductListScreen

### Test Scenario 4: Shopping Cart
1. **Tap "Cart" tab** (third icon)
2. **You see**: CartScreen with your items
3. **Observe**:
   - Each cart item with image, name, price
   - Quantity controls (+/-)
   - Order summary card showing:
     - Subtotal
     - Tax (8%)
     - Service Fee ($1.50)
     - Total
4. **Tap "+" on an item**: Quantity increases
5. **Observe**: All totals update automatically
6. **Tap "-" on an item**: Quantity decreases
7. **If quantity reaches 0**: Item removed from cart
8. **Tap "Add More Items" button**: Navigate to Menu tab
9. **Add more products**, then return to cart
10. **Tap "Place Order" button**
11. **Confirm dialog appears**: Tap "Confirm"
12. **Result**: Cart clears, success message shows

### Test Scenario 5: Profile & Logout
1. **Tap "Profile" tab** (fourth icon)
2. **You see**: ProfileScreen with user info
3. **Scroll through sections**:
   - Personal Information
   - Settings
   - About
4. **Tap logout card** (red card at bottom)
5. **Confirm dialog**: Tap "Logout"
6. **Result**: Return to LoginScreen

### Test Scenario 6: Complete User Journey
1. **Start**: LoginScreen
2. **Login** → HomeScreen
3. **View popular products** on HomeScreen
4. **Tap "Menu"** → ProductListScreen
5. **Search "chocolate"** → Filtered results
6. **Tap "Chocolate Donut"** → ProductDetailScreen
7. **Set quantity to 3**
8. **Add to cart** → SnackBar confirmation
9. **Back to list**
10. **Select "Shakes" category**
11. **Tap "Coffee Shake"** → ProductDetailScreen
12. **Add to cart (quantity 1)**
13. **Check cart badge** → Shows "4" (3 + 1)
14. **Tap "Cart" tab** → CartScreen
15. **Review order** → See 2 items, totals calculated
16. **Place order** → Confirm
17. **Success** → Cart cleared
18. **Tap "Profile"** → ProfileScreen
19. **Logout** → Back to LoginScreen

## 🔧 Development Commands

### Hot Reload (While App is Running)
```bash
# Press 'r' in terminal
r
# or
R  # for hot restart
```

### Common Flutter Commands

```bash
# Clean build artifacts
flutter clean

# Rebuild dependencies
flutter pub get

# Run with specific mode
flutter run --release        # Release mode (optimized)
flutter run --profile         # Profile mode (performance testing)

# Run on web
flutter run -d chrome --web-renderer html    # HTML renderer
flutter run -d chrome --web-renderer canvaskit  # CanvasKit renderer

# Build APK (Android)
flutter build apk

# Build app bundle (Android)
flutter build appbundle

# Build for web
flutter build web

# Build for Windows
flutter build windows
```

### Debugging

```bash
# Enable verbose logging
flutter run -v

# Check for issues
flutter doctor -v

# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests (if you add them)
flutter test
```

## 🐛 Troubleshooting

### Issue: "Flutter command not found"
**Solution:**
```bash
# Add Flutter to PATH
# Windows: Add C:\path\to\flutter\bin to System Environment Variables
# Mac/Linux: Add to ~/.bashrc or ~/.zshrc:
export PATH="$PATH:/path/to/flutter/bin"
```

### Issue: Dependencies not resolving
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: Build errors
**Solution:**
```bash
flutter doctor
# Fix any issues shown
flutter pub upgrade
```

### Issue: Hot reload not working
**Solution:**
- Press `R` (capital R) for hot restart
- Or restart the app completely

### Issue: App not showing on device
**Solution:**
```bash
# Check connected devices
flutter devices

# If no devices, start emulator or connect phone
# Then run again
flutter run
```

### Issue: "Gradle build failed" (Android)
**Solution:**
1. Make sure Android SDK is installed
2. Run `flutter doctor` and follow suggestions
3. Update Gradle if needed

### Issue: Web app not loading
**Solution:**
```bash
# Try different renderer
flutter run -d chrome --web-renderer html

# Clear browser cache
# Restart browser
```

## 📊 Performance Tips

### For Faster Development
```bash
# Use hot reload instead of hot restart when possible
# Keep emulator running (don't close between runs)
# Use physical device for better performance
```

### For Production Builds
```bash
# Always build in release mode
flutter build apk --release
flutter build web --release

# Optimize web build
flutter build web --web-renderer canvaskit --release
```

## 🎯 Key Features to Test

- [ ] Login form validation (try invalid email, short password)
- [ ] Search functionality in product list
- [ ] Category filtering (try each category)
- [ ] Product card tapping → Detail screen
- [ ] Quantity adjustment in detail screen
- [ ] Add to cart from detail screen
- [ ] Cart badge updates
- [ ] Cart item quantity controls
- [ ] Order summary calculations (math should be correct)
- [ ] Place order flow
- [ ] Empty cart state
- [ ] Profile information display
- [ ] Logout flow
- [ ] Dark mode (if system is in dark mode)

## 📱 Keyboard Shortcuts (While Running)

| Key | Action |
|-----|--------|
| `r` | Hot reload |
| `R` | Hot restart |
| `h` | Help menu |
| `q` | Quit |
| `p` | Show performance overlay |
| `P` | Toggle platform (Android/iOS simulation) |
| `o` | Toggle platform brightness |

## 🎨 Visual Checks

### Things to Verify Visually:
1. **Colors**: Golden theme (#D4A574) should be visible
2. **Icons**: Coffee icons as placeholders
3. **Typography**: Material 3 text styles
4. **Spacing**: Consistent padding and margins
5. **Cards**: Rounded corners (12dp radius)
6. **Navigation**: Smooth transitions
7. **Badge**: Cart count visible on navigation bar
8. **Snackbars**: Appear from bottom
9. **Dialogs**: Centered with proper actions
10. **Responsive**: Works in portrait and landscape

## 📸 Expected Screenshots

### LoginScreen
- Large coffee icon at top
- "Welcome Back" title
- Email and password fields
- Login button
- Register link

### HomeScreen
- Profile avatar and greeting
- Welcome card
- "Popular Items" section with 3 products
- Featured carousel
- Customer review card

### ProductListScreen (Master)
- "Our Menu" title
- Search bar
- Category chips (All, Hot Coffee, etc.)
- Product cards in vertical list
- Each card shows image, name, description, price, Add button

### ProductDetailScreen (Detail)
- Large product image/icon at top
- Product name and Popular badge
- Category and prep time
- Full description
- Price in highlighted card
- Quantity selector
- "Add to Cart" button with total

### CartScreen
- "My Cart" title with item count
- List of cart items with +/- controls
- Order summary card
- "Place Order" button

### ProfileScreen
- Profile avatar and name
- Personal info section
- Settings section
- About section
- Red logout card

## ✅ Success Criteria

Your app is working correctly if:

1. ✅ Login screen accepts any email/password
2. ✅ Bottom navigation switches between 4 tabs
3. ✅ ProductListScreen shows all 13 products
4. ✅ Search filters products in real-time
5. ✅ Category chips filter by category
6. ✅ Tapping product opens detail screen
7. ✅ Detail screen shows all product info
8. ✅ Quantity selector works correctly
9. ✅ Add to cart updates badge immediately
10. ✅ Cart shows correct items and calculations
11. ✅ Place order clears cart and shows success
12. ✅ Logout returns to login screen
13. ✅ No errors in console
14. ✅ Smooth navigation throughout

## 🎓 Next Steps After Testing

1. **Customize**: Change colors in `theme.dart`
2. **Add Images**: Replace Icons.coffee with real images
3. **Enhance**: Add animations and transitions
4. **Persist**: Add local storage for cart
5. **Backend**: Connect to API for real data
6. **Deploy**: Build and release to stores

## 📞 Getting Help

If you encounter issues:

1. Check Flutter documentation: https://flutter.dev/docs
2. Search Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
3. Flutter Discord: https://discord.gg/flutter
4. GitHub Issues: https://github.com/flutter/flutter/issues

---

**Happy Testing! 🎉**

The app should run smoothly and demonstrate the complete Master/Detail pattern with full e-commerce functionality.
