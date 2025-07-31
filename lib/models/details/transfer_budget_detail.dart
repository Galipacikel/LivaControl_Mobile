import 'approve_form_detail.dart';

class TransferBudgetDetail extends ApproveFormDetail {
  final String fromBudget;
  final String toBudget;
  final double transferAmount;

  TransferBudgetDetail({required this.fromBudget, required this.toBudget, required this.transferAmount});

  factory TransferBudgetDetail.fromJson(Map<String, dynamic> json) {
    return TransferBudgetDetail(
      fromBudget: json['FromBudget'] as String? ?? '',
      toBudget: json['ToBudget'] as String? ?? '',
      transferAmount: (json['TransferAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'FromBudget': fromBudget,
      'ToBudget': toBudget,
      'TransferAmount': transferAmount,
    };
  }
} 