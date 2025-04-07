import 'package:uuid/uuid.dart';

enum TransactionType {
  expense,
  payment,
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String? description;
  final DateTime date;
  final String payerId;
  final Map<String, double> participants;
  final String? receiptImagePath;
  final TransactionType type;
  final String? activityId;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    this.description,
    required this.date,
    required this.payerId,
    required this.participants,
    this.receiptImagePath,
    required this.type,
    this.activityId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'payerId': payerId,
      'participants': participants,
      'receiptImagePath': receiptImagePath,
      'type': type.index,
      'activityId': activityId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      payerId: json['payerId'],
      participants: Map<String, double>.from(
        json['participants'].map((key, value) => MapEntry(key, value.toDouble())),
      ),
      receiptImagePath: json['receiptImagePath'],
      type: TransactionType.values[json['type']],
      activityId: json['activityId'],
    );
  }
} 