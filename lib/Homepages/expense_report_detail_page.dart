import 'package:flutter/material.dart';
import '../models/expense_report.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import 'package:dotted_line/dotted_line.dart';

class ExpenseReportDetailPage extends StatelessWidget {
  final ExpenseReport report;
  final bool showApproveActions;
  const ExpenseReportDetailPage({
    super.key,
    required this.report,
    this.showApproveActions = false,
  });

  void _handleAction(BuildContext context, ExpenseReportStatus newStatus) {
    final updated = ExpenseReport(
      id: report.id,
      name: report.name,
      status: newStatus,
      expenses: report.expenses,
      totalAmount: report.totalAmount,
      category: report.category,
    );
    Navigator.pop(context, updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == ExpenseReportStatus.approved
              ? 'Gider onaylandı'
              : 'Gider reddedildi',
        ),
        backgroundColor: newStatus == ExpenseReportStatus.approved
            ? Colors.green
            : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    final labelFontSize = size.width < 350 ? 13.0 : 15.0;
    final valueFontSize = size.width < 350 ? 14.0 : 17.0;
    final user = Provider.of<SessionProvider>(context).currentUser;
    final isAdmin = user != null && user.role == 'admin';
    final canApprove =
        showApproveActions &&
        isAdmin &&
        report.status == ExpenseReportStatus.sent;


    String statusText;
    switch (report.status) {
      case ExpenseReportStatus.sent:
        statusText = 'Onay Bekliyor';
        break;
      case ExpenseReportStatus.approved:
        statusText = 'Onaylandı';
        break;
      case ExpenseReportStatus.rejected:
        statusText = 'Reddedildi';
        break;
      default:
        statusText = 'Oluşturuldu';
    }

    Widget buildRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: labelFontSize, color: Colors.black87),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    Widget buildDottedLine() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: DottedLine(
        dashColor: Color(0xFFB0ADAD),
        lineThickness: 1,
        dashLength: 4,
        dashGapLength: 3,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gider Raporu Detayı'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRow('Rapor Adı', report.name),
            buildDottedLine(),
            buildRow('Durum', statusText),
            buildDottedLine(),
            buildRow('Kategori', report.category),
            buildDottedLine(),
            buildRow(
              'Toplam Tutar',
              '${report.totalAmount.toStringAsFixed(2)} GBP',
            ),
            buildDottedLine(),
            buildRow('Gider Sayısı', '${report.expenses.length}'),
            buildDottedLine(),
            if (report.expenses.isNotEmpty) ...[
              buildRow(
                'İlk Gider Açıklama',
                report.expenses.first.desc,
              ),
              buildDottedLine(),
              buildRow(
                'İlk Gider Tutar',
                '${report.expenses.first.amount.toStringAsFixed(2)} GBP',
              ),
              buildDottedLine(),
              buildRow(
                'İlk Gider Tarih',
                '${report.expenses.first.date.day.toString().padLeft(2, '0')}/${report.expenses.first.date.month.toString().padLeft(2, '0')}/${report.expenses.first.date.year}'
              ),
              buildDottedLine(),
              buildRow(
                'İlk Gider Kategori',
                report.expenses.first.category,
              ),
              buildDottedLine(),
            ],
            const SizedBox(height: 18),
            Text(
              'Ekli Fiş / Fotoğraf',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: labelFontSize + 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: Color(0xFFB0ADAD),
                ),
              ),
            ),
            if (canApprove) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () =>
                          _handleAction(context, ExpenseReportStatus.approved),
                      child: const Text(
                        'Onayla',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () =>
                          _handleAction(context, ExpenseReportStatus.rejected),
                      child: const Text(
                        'Reddet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
