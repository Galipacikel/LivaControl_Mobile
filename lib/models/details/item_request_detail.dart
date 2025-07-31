import 'approve_form_detail.dart';

class ItemRequestDetail extends ApproveFormDetail {
  final String requestedItem;
  final int requestedQty;

  ItemRequestDetail({required this.requestedItem, required this.requestedQty});

  factory ItemRequestDetail.fromJson(Map<String, dynamic> json) {
    return ItemRequestDetail(
      requestedItem: json['RequestedItem'] as String? ?? '',
      requestedQty: json['RequestedQty'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'RequestedItem': requestedItem,
      'RequestedQty': requestedQty,
    };
  }
} 