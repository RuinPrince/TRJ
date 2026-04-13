import 'dart:math';
import 'package:intl/intl.dart';

class AppHelpers {
  // A private constructor prevents instantiation
  AppHelpers._();

  // ==========================================
  // FORMATTING FUNCTIONS
  // ==========================================

  /// Formats a double into Indian Rupee currency string
  /// Equivalent to PHP's formatCurrency()
  static String formatCurrency(double amount) {
    // Uses the Indian locale for proper comma placement (e.g., ₹1,00,000.00)
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  /// Formats a DateTime object into a readable string
  /// Equivalent to PHP's formatDate()
  static String formatDate(DateTime? date, {String format = 'd MMM, yyyy'}) {
    if (date == null) return '';
    return DateFormat(format).format(date);
  }

  // ==========================================
  // GENERATOR FUNCTIONS
  // ==========================================

  /// Generates a random alphanumeric string
  /// Equivalent to PHP's generateRandomString()
  static String generateRandomString([int length = 10]) {
    const String chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random rnd = Random();
    
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  /// Generates a unique transaction ID
  /// Equivalent to PHP's generateTransactionId()
  static String generateTransactionId() {
    final now = DateTime.now();
    // Format date as YYYYMMDD
    final dateString = DateFormat('yyyyMMdd').format(now);
    final randomPart = generateRandomString(6);
    
    return 'TXN$dateString$randomPart';
  }
}