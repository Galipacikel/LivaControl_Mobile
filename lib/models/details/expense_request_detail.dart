import 'approve_form_detail.dart';

class ExpenseRequestDetail extends ApproveFormDetail {
  final String expenseType;
  final double amount;

  ExpenseRequestDetail({required this.expenseType, required this.amount});

  factory ExpenseRequestDetail.fromJson(Map<String, dynamic> json) {
    return ExpenseRequestDetail(
      expenseType: json['ExpenseType'] as String? ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'ExpenseType': expenseType,
      'Amount': amount,
    };
  }
} 