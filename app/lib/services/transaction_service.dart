import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'web3_service.dart';

class DonationTransaction {
  final String hash;
  final String fromAddress;
  final String toAddress;
  final BigInt amount;
  final DateTime timestamp;
  final String charityName;
  final String category;

  const DonationTransaction({
    required this.hash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.timestamp,
    required this.charityName,
    required this.category,
  });

  factory DonationTransaction.fromJson(Map<String, dynamic> json) {
    return DonationTransaction(
      hash: json['hash'] ?? '',
      fromAddress: json['fromAddress'] ?? '',
      toAddress: json['toAddress'] ?? '',
      amount: BigInt.parse(json['amount'] ?? '0'),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      charityName: json['charityName'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'amount': amount.toString(),
      'timestamp': timestamp.toIso8601String(),
      'charityName': charityName,
      'category': category,
    };
  }
}

class TransactionService {
  static const String baseUrl = 'http://localhost:8000';
  static final List<DonationTransaction> _transactions = [];
  
  // Get all transactions for a user
  static Future<List<DonationTransaction>> getUserTransactions(String userAddress) async {
    try {
      // For now, return cached transactions
      // In a real app, this would fetch from your backend
      return _transactions.where((tx) => tx.fromAddress.toLowerCase() == userAddress.toLowerCase()).toList();
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  // Add a new transaction (called after successful donation)
  static void addTransaction(DonationTransaction transaction) {
    _transactions.add(transaction);
    print('Added transaction: ${transaction.hash}');
  }

  // Get donation summary by category
  static Map<String, double> getDonationSummary(List<DonationTransaction> transactions) {
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in transactions) {
      final amountInEther = transaction.amount / BigInt.from(1e18);
      categoryTotals[transaction.category] = (categoryTotals[transaction.category] ?? 0) + amountInEther.toDouble();
    }
    
    return categoryTotals;
  }

  // Get total donated amount
  static double getTotalDonated(List<DonationTransaction> transactions) {
    return transactions.fold(0.0, (sum, tx) => sum + (tx.amount / BigInt.from(1e18)).toDouble());
  }

  // Get recent transactions (last 10)
  static List<DonationTransaction> getRecentTransactions(List<DonationTransaction> transactions) {
    final sorted = List<DonationTransaction>.from(transactions);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(10).toList();
  }
}
