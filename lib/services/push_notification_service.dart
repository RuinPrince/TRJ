import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Top-level function to handle background messages (Must be outside the class)
// This wakes up the app when a notification arrives while the app is closed.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to initialize Firebase here, do it, but usually the native Android/iOS 
  // SDKs handle the basic wake-up automatically.
  debugPrint("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  // Singleton pattern
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize Firebase Cloud Messaging
  /// Call this in main.dart right after Firebase.initializeApp()
  Future<void> init() async {
    // 1. Request permission (Crucial for iOS, Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted push notification permission');
      
      // 2. Get the unique device token (Replaces your VAPID keys)
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // 3. Listen for token refreshes (if the device rotates the token)
      _fcm.onTokenRefresh.listen(_saveTokenToFirestore);

      // 4. Setup message listeners
      _setupMessageHandlers();
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  // ==========================================
  // REPLACING notifications.php?action=subscribe
  // ==========================================
  Future<void> _saveTokenToFirestore(String token) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Instead of a separate push_subscriptions table, it's best practice in Firebase 
      // to store the token directly on the user's document or in a subcollection.
      await _firestore.collection('users').doc(userId).set({
        'fcm_token': token,
        'token_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('FCM Token saved successfully.');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // ==========================================
  // REPLACING notifications.php?action=unsubscribe
  // ==========================================
  Future<void> removeToken() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Delete the token from Firebase to stop receiving pushes
      await _fcm.deleteToken();
      
      // Remove it from Firestore
      await _firestore.collection('users').doc(userId).update({
        'fcm_token': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('Error removing token: $e');
    }
  }

  // ==========================================
  // HANDLE INCOMING MESSAGES
  // ==========================================
  void _setupMessageHandlers() {
    // 1. Handle Background Messages (App is completely closed or in background)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Handle Foreground Messages (App is currently open on the screen)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received a foreground message: ${message.messageId}');
      
      if (message.notification != null) {
        // In Flutter, foreground notifications don't show a system popup automatically.
        // You would typically use the 'flutter_local_notifications' package here 
        // to show a custom banner, or trigger an in-app Snackbar.
        debugPrint('Notification Title: ${message.notification?.title}');
        debugPrint('Notification Body: ${message.notification?.body}');
      }
    });

    // 3. Handle Notification Taps (User taps the push notification from the OS tray)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User tapped a notification causing the app to open!');
      
      // Example routing based on data payload
      // if (message.data['type'] == 'payment_due') {
      //   Navigator.pushNamed(context, '/payments');
      // }
    });
  }
}