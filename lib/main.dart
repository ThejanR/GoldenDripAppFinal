import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/temperature_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/location_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/theme.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  await ApiService.initialize();

  runApp(const GoldenDripApp());
}

class GoldenDripApp extends StatelessWidget {
  const GoldenDripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => TemperatureProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider()..initialize(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Golden Drip Coffee',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
