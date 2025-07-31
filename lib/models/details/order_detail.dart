import 'approve_form_detail.dart';

class OrderDetail extends ApproveFormDetail {
  final String orderNumber;
  final String supplierName;

  OrderDetail({required this.orderNumber, required this.supplierName});

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderNumber: json['OrderNumber'] as String? ?? '',
      supplierName: json['SupplierName'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'OrderNumber': orderNumber,
      'SupplierName': supplierName,
    };
  }
} 