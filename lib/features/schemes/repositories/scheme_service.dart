import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchemeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // 1. FETCH AVAILABLE SCHEMES (Global Catalog)
  // Replaces: SELECT * FROM schemes WHERE status = 'active'
  // ==========================================
  Future<List<Map<String, dynamic>>> getAvailableSchemes() async {
    try {
      final querySnapshot = await _firestore
          .collection('schemes')
          .where('status', isEqualTo: 'active')
          .orderBy('scheme_name')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Inject the document ID into the map
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching available schemes: $e');
      return [];
    }
  }

  // ==========================================
  // 2. FETCH CUSTOMER ENROLLED SCHEMES
  // Replaces: get_customer_schemes.php
  // ==========================================
  Future<List<Map<String, dynamic>>> getCustomerSchemes(String customerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('customer_schemes')
          .where('customer_id', isEqualTo: customerId)
          .orderBy('start_date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Convert Firestore Timestamps to readable strings for UI
        if (data['next_payment_date'] != null) {
          DateTime date = (data['next_payment_date'] as Timestamp).toDate();
          data['next_payment_formatted'] = '${date.day}/${date.month}/${date.year}';
        }
        
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching customer schemes: $e');
      return [];
    }
  }

  // ==========================================
  // 3. JOIN A SCHEME (Customer Action)
  // Replaces: POST join_scheme logic in schemes.php
  // ==========================================
  Future<Map<String, dynamic>> joinScheme({
    required Map<String, dynamic> masterScheme,
    required bool autoDebit,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {'success': false, 'error': 'User not logged in'};

      final now = DateTime.now();
      // Calculate next payment date (1 month from today)
      final nextPayment = DateTime(now.year, now.month + 1, now.day);

      // Create the enrollment document
      await _firestore.collection('customer_schemes').add({
        'customer_id': userId,
        'scheme_id': masterScheme['id'],
        // Denormalized data for easy UI rendering
        'scheme_name': masterScheme['scheme_name'],
        'scheme_type': masterScheme['scheme_type'],
        'monthly_amount': masterScheme['monthly_amount'],
        'tenure_months': masterScheme['tenure_months'],
        
        // Progress tracking
        'paid_months': 0,
        'total_gold_accumulated': 0.0,
        'missed_months': 0,
        'auto_debit': autoDebit,
        'status': 'active', // active, maturity, completed, cancelled
        
        // Dates
        'start_date': FieldValue.serverTimestamp(),
        'next_payment_date': Timestamp.fromDate(nextPayment),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==========================================
  // 4. ADMIN ACTIONS (Add, Edit, Archive)
  // Replaces: schemes.php action handlers
  // ==========================================
  
  Future<Map<String, dynamic>> addScheme(Map<String, dynamic> schemeData) async {
    try {
      schemeData['created_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('schemes').add(schemeData);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateScheme(String schemeId, Map<String, dynamic> schemeData) async {
    try {
      schemeData['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('schemes').doc(schemeId).update(schemeData);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> archiveScheme(String schemeId) async {
    try {
      // 1. Check if customers are actively using this scheme (Like the PHP warning)
      final activeUsersQuery = await _firestore
          .collection('customer_schemes')
          .where('scheme_id', isEqualTo: schemeId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (activeUsersQuery.docs.isNotEmpty) {
        return {
          'success': false, 
          'error': 'Cannot archive scheme. It currently has active customers.'
        };
      }

      // 2. If safe, archive it
      await _firestore.collection('schemes').doc(schemeId).update({
        'status': 'archived',
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}