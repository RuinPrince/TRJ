import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // 1. FETCH USER PROFILE
  // ==========================================
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // ==========================================
  // 2. UPDATE USER PROFILE (Replaces PHP Update logic)
  // ==========================================
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      // Add the updated_at timestamp just like your PHP NOW() function
      final Map<String, dynamic> updateData = {
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update(updateData);

      // If email was updated, we should also update it in Firebase Auth
      if (data.containsKey('email') && data['email'] != _auth.currentUser?.email) {
        await _auth.currentUser?.verifyBeforeUpdateEmail(data['email']);
        // Note: The user will need to verify the new email before it takes effect in Auth.
      }

      return {'success': true};
    } catch (e) {
      print('Error updating profile: $e');
      return {'success': false, 'error': 'Failed to update profile. Please try again.'};
    }
  }

  // ==========================================
  // 3. FETCH CUSTOMER STATS (Replaces subqueries in customer_details.php)
  // ==========================================
  /// In customer_details.php, you fetched active_schemes, completed_schemes, and total_investment.
  /// This method replicates that logic using Firestore queries.
  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      // 1. Count Active Schemes
      final AggregateQuerySnapshot activeSchemesSnapshot = await _firestore
          .collection('customer_schemes')
          .where('customer_id', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .count()
          .get();

      // 2. Count Completed Schemes
      final AggregateQuerySnapshot completedSchemesSnapshot = await _firestore
          .collection('customer_schemes')
          .where('customer_id', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      // 3. Calculate Total Investment (Summing completed payments)
      final QuerySnapshot paymentsSnapshot = await _firestore
          .collection('payments')
          .where('customer_id', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      double totalInvestment = 0.0;
      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalInvestment += (data['amount'] ?? 0.0).toDouble();
      }

      return {
        'active_schemes': activeSchemesSnapshot.count ?? 0,
        'completed_schemes': completedSchemesSnapshot.count ?? 0,
        'total_investment': totalInvestment,
      };
    } catch (e) {
      print('Error fetching customer stats: $e');
      return {
        'active_schemes': 0,
        'completed_schemes': 0,
        'total_investment': 0.0,
      };
    }
  }
}