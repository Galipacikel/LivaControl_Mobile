import '../approve_form.dart';
import 'purchase_detail.dart';
import 'order_detail.dart';
import 'item_request_detail.dart';
import 'expense_request_detail.dart';
import 'invoice_detail.dart';
import 'add_budget_detail.dart';
import 'transfer_budget_detail.dart';
import 'data_creation_req_detail.dart';

abstract class ApproveFormDetail {
  const ApproveFormDetail();

  Map<String, dynamic> toJson();

  factory ApproveFormDetail.fromJson(
      ApproveFormType type, Map<String, dynamic> json) {
    switch (type) {
      case ApproveFormType.purchase:
        return PurchaseDetail.fromJson(json);
      case ApproveFormType.order:
        return OrderDetail.fromJson(json);
      case ApproveFormType.itemRequest:
        return ItemRequestDetail.fromJson(json);
      case ApproveFormType.expenseRequest:
        return ExpenseRequestDetail.fromJson(json);
      case ApproveFormType.invoice:
        return InvoiceDetail.fromJson(json);
      case ApproveFormType.addBudget:
        return AddBudgetDetail.fromJson(json);
      case ApproveFormType.transferBudget:
        return TransferBudgetDetail.fromJson(json);
      case ApproveFormType.dataCreationReq:
        return DataCreationReqDetail.fromJson(json);
      default:
        return UnknownDetail();
    }
  }
}

class UnknownDetail extends ApproveFormDetail {
  const UnknownDetail();
  @override
  Map<String, dynamic> toJson() => {};
} 