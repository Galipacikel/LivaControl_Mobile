import 'approve_form_detail.dart';

class AddBudgetDetail extends ApproveFormDetail {
  final String budgetName;
  final double addedAmount;

  AddBudgetDetail({required this.budgetName, required this.addedAmount});

  factory AddBudgetDetail.fromJson(Map<String, dynamic> json) {
    return AddBudgetDetail(
      budgetName: json['BudgetName'] as String? ?? '',
      addedAmount: (json['AddedAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'BudgetName': budgetName,
      'AddedAmount': addedAmount,
    };
  }
} 