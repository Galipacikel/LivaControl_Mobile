/// API den gelen onay formları için model
/// Approve form types
/// Purchase: satın alma talepleri
/// Order: satın alma siparişleri
/// ItemRequest: stoktan malzeme talepleri
/// ExpenseRequest: masraf talepleri
/// Invoice: faturalar
/// AddBudget: ek bütçe talepleri
/// TransferBudget: transfer bütçe talepleri
/// DataCreationReq: yeni ana veri oluşturma talepleri
import 'details/approve_form_detail.dart';

enum ApproveFormType {
  purchase,
  order,
  itemRequest,
  expenseRequest,
  invoice,
  addBudget,
  transferBudget,
  dataCreationReq,
  unknown,
}

ApproveFormType approveFormTypeFromString(String? type) {
  switch (type) {
    case 'Purchase':
      return ApproveFormType.purchase;
    case 'Order':
      return ApproveFormType.order;
    case 'ItemRequest':
      return ApproveFormType.itemRequest;
    case 'ExpenseRequest':
      return ApproveFormType.expenseRequest;
    case 'Invoice':
      return ApproveFormType.invoice;
    case 'AddBudget':
      return ApproveFormType.addBudget;
    case 'TransferBudget':
      return ApproveFormType.transferBudget;
    case 'DataCreationReq':
      return ApproveFormType.dataCreationReq;
    default:
      return ApproveFormType.unknown;
  }
}

String approveFormTypeToString(ApproveFormType type) {
  switch (type) {
    case ApproveFormType.purchase:
      return 'Purchase';
    case ApproveFormType.order:
      return 'Order';
    case ApproveFormType.itemRequest:
      return 'ItemRequest';
    case ApproveFormType.expenseRequest:
      return 'ExpenseRequest';
    case ApproveFormType.invoice:
      return 'Invoice';
    case ApproveFormType.addBudget:
      return 'AddBudget';
    case ApproveFormType.transferBudget:
      return 'TransferBudget';
    case ApproveFormType.dataCreationReq:
      return 'DataCreationReq';
    case ApproveFormType.unknown:
      return 'Unknown';
  }
}

class ApproveForm {
  final int approvFormStatusId;
  final String formId;
  final String? cUser;
  final String userId;
  final int? priority;
  final int status;
  final String statusNm;
  final DateTime? date;
  final ApproveFormType type;
  final String exUserNm;
  final String nextUserNm;
  final String code;
  final String message;
  final double? actualBudget;
  final int? actualStock;
  final bool? purchased;
  final double amount;
  final String note;
  final String masterDataTypeNm;
  final String fromDepNm;
  final String fromExpItemNm;
  final int? fromY;
  final int? fromM;
  final String toDepNm;
  final String toExpItemNm;
  final int? toY;
  final int? toM;
  final String currNm;
  final int? currId;
  final int? addBudgetTypeId;
  final String? relatedFormId;
  final String? relatedFormItemId;
  final String approvNotes;
  final ApproveFormDetail? detail;

  ApproveForm({
    required this.approvFormStatusId,
    required this.formId,
    required this.cUser,
    required this.userId,
    required this.priority,
    required this.status,
    required this.statusNm,
    required this.date,
    required this.type,
    required this.exUserNm,
    required this.nextUserNm,
    required this.code,
    required this.message,
    required this.actualBudget,
    required this.actualStock,
    required this.purchased,
    required this.amount,
    required this.note,
    required this.masterDataTypeNm,
    required this.fromDepNm,
    required this.fromExpItemNm,
    required this.fromY,
    required this.fromM,
    required this.toDepNm,
    required this.toExpItemNm,
    required this.toY,
    required this.toM,
    required this.currNm,
    required this.currId,
    required this.addBudgetTypeId,
    required this.relatedFormId,
    required this.relatedFormItemId,
    required this.approvNotes,
    required this.detail,
  });

  factory ApproveForm.fromJson(Map<String, dynamic> json) {
    return ApproveForm(
      approvFormStatusId: json['ApprovFormStatusID'] as int,
      formId: json['FormID'] as String,
      cUser: json['CUser'] as String?,
      userId: json['UserID'].toString(),
      priority: json['Priority'] as int?,
      status: json['Status'] as int,
      statusNm: json['StatusNm'] as String? ?? '',
      date: json['Date'] != null ? DateTime.tryParse(json['Date']) : null,
      type: approveFormTypeFromString(json['Type'] as String?),
      exUserNm: json['ExUserNm'] as String? ?? '',
      nextUserNm: json['NextUserNm'] as String? ?? '',
      code: json['Code'] as String? ?? '',
      message: json['Message'] as String? ?? '',
      actualBudget: (json['ActualBudget'] as num?)?.toDouble(),
      actualStock: json['ActualStock'] as int?,
      purchased: json['Purchased'] as bool?,
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      note: json['Note'] as String? ?? '',
      masterDataTypeNm: json['MasterDataTypeNm'] as String? ?? '',
      fromDepNm: json['FromDepNm'] as String? ?? '',
      fromExpItemNm: json['FromExpItemNm'] as String? ?? '',
      fromY: json['FromY'] as int?,
      fromM: json['FromM'] as int?,
      toDepNm: json['ToDepNm'] as String? ?? '',
      toExpItemNm: json['ToExpItemNm'] as String? ?? '',
      toY: json['ToY'] as int?,
      toM: json['ToM'] as int?,
      currNm: json['CurrNm'] as String? ?? '',
      currId: json['CurrId'] as int?,
      addBudgetTypeId: json['AddBudgetTypeId'] as int?,
      relatedFormId: json['RelatedFormId']?.toString(),
      relatedFormItemId: json['RelatedFormItemId']?.toString(),
      approvNotes: json['ApprovNotes'] as String? ?? '',
      detail: json['Detail'] != null
          ? ApproveFormDetail.fromJson(
              approveFormTypeFromString(json['Type'] as String?),
              json['Detail'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ApprovFormStatusID': approvFormStatusId,
      'FormID': formId,
      'CUser': cUser,
      'UserID': userId,
      'Priority': priority,
      'Status': status,
      'StatusNm': statusNm,
      'Date': date?.toIso8601String(),
      'Type': approveFormTypeToString(type),
      'ExUserNm': exUserNm,
      'NextUserNm': nextUserNm,
      'Code': code,
      'Message': message,
      'ActualBudget': actualBudget,
      'ActualStock': actualStock,
      'Purchased': purchased,
      'Amount': amount,
      'Note': note,
      'MasterDataTypeNm': masterDataTypeNm,
      'FromDepNm': fromDepNm,
      'FromExpItemNm': fromExpItemNm,
      'FromY': fromY,
      'FromM': fromM,
      'ToDepNm': toDepNm,
      'ToExpItemNm': toExpItemNm,
      'ToY': toY,
      'ToM': toM,
      'CurrNm': currNm,
      'CurrId': currId,
      'AddBudgetTypeId': addBudgetTypeId,
      'RelatedFormId': relatedFormId,
      'RelatedFormItemId': relatedFormItemId,
      'ApprovNotes': approvNotes,
      'Detail': detail?.toJson(),
    };
  }

  static List<ApproveForm> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => ApproveForm.fromJson(e as Map<String, dynamic>)).toList();
  }
} 