import 'package:uuid/uuid.dart';

enum TransactionType {
  expense,
  settlement,
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String? description;
  final DateTime date;
  final String payerId;
  final Map<String, double> participants;
  final TransactionType type;
  final String? notes;
  final String? receiptImagePath;
  final String? groupId;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    this.description,
    required this.date,
    required this.payerId,
    required this.participants,
    this.notes,
    this.receiptImagePath,
    this.groupId,
    required this.type,
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
      'type': type.toString(),
      'notes': notes,
      'receiptImagePath': receiptImagePath,
      'groupId': groupId,
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
      participants: Map<String, double>.from(json['participants']),
      type: json['type'] == 'TransactionType.expense'
          ? TransactionType.expense
          : TransactionType.settlement,
      notes: json['notes'],
      receiptImagePath: json['receiptImagePath'],
      groupId: json['groupId'],
    );
  }
} 