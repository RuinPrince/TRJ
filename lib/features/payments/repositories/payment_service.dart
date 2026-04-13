import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // 1. FETCH PAYMENT HISTORY (Replaces getCustomerPayments)
  // ==========================================
  Future<List<Map<String, dynamic>>> getPaymentHistory({int limit = 20}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      // Equivalent to: SELECT * FROM payments WHERE customer_id = ? ORDER BY payment_date DESC
      final QuerySnapshot snapshot = await _firestore
          .collection('payments')
          .where('customer_id', isEqualTo: userId)
          .orderBy('payment_date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convert Firestore Timestamp to DateTime for the UI
        DateTime? date;
        if (data['payment_date'] is Timestamp) {
          date = (data['payment_date'] as Timestamp).toDate();
        }

        return {
          'id': doc.id,
          'transaction_id': data['transaction_id'] ?? 'N/A',
          'scheme_name': data['scheme_name'] ?? 'Unknown Scheme',
          'amount': (data['amount'] ?? 0.0).toDouble(),
          'method': data['payment_method'] ?? 'Unknown',
          'status': data['status'] ?? 'pending',
          'date_time': date,
        };
      }).toList();
    } catch (e) {
      print('Error fetching payment history: $e');
      return [];
    }
  }

  // ==========================================
  // 2. GET NEXT PAYMENT DETAILS (Replaces get_next_payment.php logic)
  // ==========================================
  Future<Map<String, dynamic>> getNextPaymentDetails(String customerSchemeId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('customer_schemes')
          .doc(customerSchemeId)
          .get();

      if (!doc.exists) {
        return {'success': false, 'error': 'Scheme not found'};
      }

      final data = doc.data() as Map<String, dynamic>;
      
      final String status = data['status'] ?? 'active';
      final int paidMonths = data['paid_months'] ?? 0;
      final int tenureMonths = data['tenure_months'] ?? 11;
      final double monthlyAmount = (data['monthly_amount'] ?? 0).toDouble();
      
      DateTime nextDueDate = DateTime.now();
      if (data['next_payment_date'] is Timestamp) {
        nextDueDate = (data['next_payment_date'] as Timestamp).toDate();
      }

      // 1. Check if scheme is completed or archived
      if (status == 'completed' || status == 'archived') {
        return {
          'success': true,
          'can_pay': false,
          'reason': 'Scheme is $status',
          'amount': 0.0,
        };
      }

      // 2. Check if all months are paid
      if (paidMonths >= tenureMonths) {
        return {
          'success': true,
          'can_pay': false,
          'reason': 'All installments paid. Awaiting maturity.',
          'amount': 0.0,
        };
      }

      // 3. Calculate Missed Months and Overdue Amounts
      // This replicates your PHP logic: checking if the current date is past the due date
      final DateTime now = DateTime.now();
      int monthsDue = 1;
      double lateFee = 0.0;

      if (now.isAfter(nextDueDate)) {
        // Calculate how many months they are behind
        final int daysOverdue = now.difference(nextDueDate).inDays;
        
        if (daysOverdue > 30) {
          // E.g., if they are 45 days late, they owe for 2 months
          monthsDue = (daysOverdue / 30).floor() + 1;
        }

        // Apply late fee logic if you have any (Example: ₹50 per missed month)
        // lateFee = (monthsDue - 1) * 50.0; 
      } else {
        // If they are trying to pay before the due date, check if early payments are allowed.
        // Replicating your PHP: "check if current month is already paid"
        // If the next due date is more than 30 days away, they might have already paid for this cycle.
        if (nextDueDate.difference(now).inDays > 25) {
           return {
            'success': true,
            'can_pay': false,
            'reason': 'Installment already paid for this month.',
            'amount': 0.0,
          };
        }
      }

      // Cap the months due to the remaining tenure
      final int remainingMonths = tenureMonths - paidMonths;
      if (monthsDue > remainingMonths) {
        monthsDue = remainingMonths;
      }

      final double totalAmountDue = (monthlyAmount * monthsDue) + lateFee;

      return {
        'success': true,
        'can_pay': true,
        'amount': totalAmountDue,
        'base_amount': monthlyAmount,
        'months_due': monthsDue,
        'late_fee': lateFee,
        'next_due_date': nextDueDate,
      };

    } catch (e) {
      print('Error calculating next payment: $e');
      return {'success': false, 'error': 'Failed to calculate payment details'};
    }
  }

  // ==========================================
  // 3. GET RECEIPT DETAILS (For ReceiptScreen)
  // ==========================================
  Future<Map<String, dynamic>?> getReceiptDetails(String transactionId) async {
    try {
      // Query the specific transaction
      final QuerySnapshot snapshot = await _firestore
          .collection('payments')
          .where('transaction_id', isEqualTo: transactionId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      // In a real scenario, you might also need to fetch the customer profile 
      // or scheme details here if they aren't duplicated on the payment document.
      
      return {
        ...data,
        'payment_date': (data['payment_date'] as Timestamp?)?.toDate(),
      };
    } catch (e) {
      print('Error fetching receipt: $e');
      return null;
    }
  }
}