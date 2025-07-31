import 'approve_form_detail.dart';

class PurchaseDetail extends ApproveFormDetail {
  final String itemName;
  final int quantity;

  PurchaseDetail({required this.itemName, required this.quantity});

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      itemName: json['ItemName'] as String? ?? '',
      quantity: json['Quantity'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'ItemName': itemName,
      'Quantity': quantity,
    };
  }
} 