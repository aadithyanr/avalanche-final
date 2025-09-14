import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/web3_service.dart';
import 'services/toast_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  // Initialize Web3 service with error handling
  try {
    await Web3Service.instance.initialize();
  } catch (e) {
    print('Web3 initialization failed: $e');
    // Continue without Web3 for web compatibility
  }
  
  final homeScreenKey = GlobalKey<HomeScreenState>();
  ToastService.instance.setHomeScreen(homeScreenKey);
  
  runApp(MyApp(homeScreenKey: homeScreenKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<HomeScreenState> homeScreenKey;

  const MyApp({super.key, required this.homeScreenKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Giving Tree',
      theme: ThemeData(
        fontFamily: 'Be Vietnam Pro',
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(key: homeScreenKey),
      },
      builder: (context, child) {
        // Make the app responsive for web
        if (kIsWeb) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400, // Mobile-like width
                maxHeight: 800, // Mobile-like height
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          );
        }
        return child!;
      },
    );
  }
}
