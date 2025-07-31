import 'approve_form_detail.dart';

class DataCreationReqDetail extends ApproveFormDetail {
  final String dataType;
  final String description;

  DataCreationReqDetail({required this.dataType, required this.description});

  factory DataCreationReqDetail.fromJson(Map<String, dynamic> json) {
    return DataCreationReqDetail(
      dataType: json['DataType'] as String? ?? '',
      description: json['Description'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'DataType': dataType,
      'Description': description,
    };
  }
} 