import 'approve_form_detail.dart';

class InvoiceDetail extends ApproveFormDetail {
  final String invoiceNumber;
  final double totalAmount;

  InvoiceDetail({required this.invoiceNumber, required this.totalAmount});

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      invoiceNumber: json['InvoiceNumber'] as String? ?? '',
      totalAmount: (json['TotalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'InvoiceNumber': invoiceNumber,
      'TotalAmount': totalAmount,
    };
  }
} 