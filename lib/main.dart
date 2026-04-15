import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Services ---
import 'services/local_storage_service.dart';
import 'services/push_notification_service.dart';

// --- Splash Screen ---
import 'features/splash/views/splash_screen.dart'; // Added the splash screen import

// --- Auth Screens ---
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/register_screen.dart';
import 'features/auth/views/forgot_password_screen.dart';

// --- Dashboard & Core Screens ---
import 'features/dashboard/views/dashboard_screen.dart';
import 'features/profile/views/profile_screen.dart';

// --- Scheme Screens ---
import 'features/schemes/views/schemes_list_screen.dart';
import 'features/schemes/views/scheme_details_screen.dart';

// --- Payment Screens ---
import 'features/payments/views/checkout_screen.dart';
import 'features/payments/views/payments_screen.dart';
import 'features/payments/views/receipt_screen.dart';

// --- Support & Settings Screens ---
import 'features/support/views/support_screen.dart';

// NOTE: If you used FlutterFire CLI, uncomment the line below:
// import 'firebase_options.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // Uncomment if using FlutterFire CLI
  );

  // 3. Initialize Custom Services
  await LocalStorageService().init();
  await PushNotificationService().init();

  // 4. Run the App
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
        
      },

      // --- Dynamic Routes (With Arguments) ---
      // Use this for screens that require specific IDs to be passed to them.
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/scheme-details':
            // Example of passing an ID, though our UI file currently doesn't require it
            // final schemeId = settings.arguments as String;
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
            return null; // Let the default routing handle unknown routes (or show a 404 screen)
        }
      },
    );
  }
}

/// A widget that listens to the Firebase Auth state and acts as a gatekeeper.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF881337)),
            ),
          );
        }

        // If the user is logged in, show the Dashboard
        if (snapshot.hasData) {
          // Note: In a production app with both Admins and Customers, you would 
          // fetch the user's role from Firestore here to decide WHICH dashboard to show.
          return const DashboardScreen(); 
        }

        // If the user is NOT logged in, show the Login Screen
        return const LoginScreen();
      },
    );
  }
}