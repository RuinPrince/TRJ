import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================
  // 1. REGISTER (Equivalent to PHP register())
  // ==========================================
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String phone,
    String? aadhar, // Optional fields from your UI
    String? pan,
  }) async {
    try {
      // 1. Check if username is already taken in Firestore
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return {'success': false, 'error': 'Username is already taken.'};
      }

      // 2. Create the user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Save the extra data to Cloud Firestore (Equivalent to INSERT INTO users)
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'aadhar': aadhar ?? '',
          'pan': pan ?? '',
          'user_type': 'customer', // Defaulting to customer as in PHP
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        return {'success': true, 'user_id': userCredential.user!.uid};
      }
      
      return {'success': false, 'error': 'Failed to create user account.'};
      
    } on FirebaseAuthException catch (e) {
      // Translate Firebase error codes into readable messages
      String message = 'Registration failed. Please try again.';
      if (e.code == 'weak-password') message = 'The password provided is too weak.';
      if (e.code == 'email-already-in-use') message = 'An account already exists for that email.';
      
      return {'success': false, 'error': message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==========================================
  // 2. LOGIN (Equivalent to PHP login())
  // ==========================================
  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      String loginEmail = usernameOrEmail;

      // Firebase Auth natively logs in with Email. 
      // If the user provided a username (no '@'), we must find their email in Firestore first.
      if (!usernameOrEmail.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: usernameOrEmail)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return {'success': false, 'error': 'Invalid credentials'}; // Mirroring PHP error
        }
        
        loginEmail = querySnapshot.docs.first.get('email');
      }

      // Authenticate with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      // Fetch user data to check status and user_type
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        
        if (data['status'] != 'active') {
          await _auth.signOut();
          return {'success': false, 'error': 'Your account has been deactivated.'};
        }

        // Update last login timestamp (Equivalent to UPDATE users SET updated_at = NOW())
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'updated_at': FieldValue.serverTimestamp(),
        });

        return {'success': true, 'user_type': data['user_type']};
      } else {
        return {'success': false, 'error': 'User profile data not found.'};
      }

    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': 'Invalid credentials'};
    } catch (e) {
      return {'success': false, 'error': 'An error occurred. Please try again.'};
    }
  }

  // ==========================================
  // 3. LOGOUT (Equivalent to PHP logout() & logout.php)
  // ==========================================
  Future<void> logout() async {
    // Firebase handles clearing the token/session automatically
    await _auth.signOut();
  }

  // ==========================================
  // 4. SESSION HELPERS (Equivalent to PHP isLoggedIn(), getUser())
  // ==========================================
  
  /// Checks if a user session is currently active
  bool get isLoggedIn {
    return _auth.currentUser != null;
  }

  /// Gets the currently logged in Firebase User ID
  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  /// Fetches the full user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_auth.currentUser != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
          
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }
}