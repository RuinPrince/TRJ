import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

// --- Services ---
import 'services/local_storage_service.dart';
import 'services/push_notification_service.dart';

// --- Splash Screen ---
import 'features/splash/views/splash_screen.dart';

// --- Auth Screens ---
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/register_screen.dart';
import 'features/auth/views/forgot_password_screen.dart';

// --- Dashboard & Core Screens ---
import 'features/dashboard/views/dashboard_screen.dart';
import 'features/profile/views/profile_screen.dart';
import 'features/dashboard/views/new_arrivals_screen.dart'; // <-- NEW SCREEN IMPORT

// --- Scheme Screens ---
import 'features/schemes/views/schemes_list_screen.dart';
import 'features/schemes/views/scheme_details_screen.dart';

// --- Payment Screens ---
import 'features/payments/views/checkout_screen.dart';
import 'features/payments/views/payments_screen.dart';
import 'features/payments/views/receipt_screen.dart';

// --- Support & Settings Screens ---
import 'features/support/views/support_screen.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Custom Services
  await LocalStorageService().init();
  //await PushNotificationService().init();

  // 3. Run the App
  runApp(const ThangaRojaApp());
}

class ThangaRojaApp extends StatelessWidget {
  const ThangaRojaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thanga Roja Jewellers',
      debugShowCheckedModeBanner: false,
      
      // --- Global Brand Theme ---
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF881337), // Primary Red
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light BG
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF881337),
          primary: const Color(0xFF881337),
          secondary: const Color(0xFFB4941F), // Primary Gold
        ),
        fontFamily: 'Roboto', // Default font, use Playfair Display for headings
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
        ),
      ),

      // --- Smart Authentication Wrapper ---
      // This automatically routes the user to the Splash Screen first.
      home: const SplashScreen(),

      // --- Standard Routes (No Arguments) ---
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/schemes': (context) => const SchemesListScreen(),
        '/payment-history': (context) => const PaymentsScreen(),
        '/support': (context) => const SupportScreen(),
        '/new-arrivals': (context) => const NewArrivalsScreen(), // <-- NEW ROUTE ADDED
      },

      // --- Dynamic Routes (With Arguments) ---
      // Use this for screens that require specific IDs to be passed to them.
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/scheme-details':
            return MaterialPageRoute(
              builder: (context) => const SchemeDetailsScreen(),
            );
            
          case '/checkout':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                customerSchemeId: args['customerSchemeId'],
                schemeName: args['schemeName'],
                amount: args['amount'],
              ),
            );
            
          case '/receipt':
            final txnId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ReceiptScreen(transactionId: txnId),
            );
            
          default:
            return null; // Let the default routing handle unknown routes
        }
      },
    );
  }
}