import 'package:flutter/material.dart';
import '../models/expense_report.dart';
import 'expense_report_detail_page.dart';
import '../add_expenses/add_expense1.dart';
import '../add_expenses/add_expense2.dart';
import '../add_expenses/add_expense3.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AllExpensesPage extends StatefulWidget {
  final List<ExpenseReport> reports;
  final String pageType; // 'created' veya 'sent'
  const AllExpensesPage({
    super.key,
    required this.reports,
    this.pageType = 'created',
  });

  @override
  State<AllExpensesPage> createState() => _AllExpensesPageState();
}

class _AllExpensesPageState extends State<AllExpensesPage> {
  late List<ExpenseReport> _reports;

  @override
  void initState() {
    super.initState();
    _reports = List<ExpenseReport>.from(widget.reports);
  }

  void _deleteReport(ExpenseReport report) {
    setState(() {
      _reports.removeWhere((r) => r.name == report.name);
    });
    // Eğer son item silindiyse veya ana ekrana dönmek istenirse:
    if (_reports.isEmpty) {
      Navigator.pop(context, report);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = widget.pageType == 'created'
        ? const Color(0xFFF57A20)
        : const Color(0xFF2C2B5B);
    String appBarTitle = 'Tüm Gider Raporlarınız';
    if (widget.pageType == 'created') {
      appBarTitle = 'Oluşturulan Gider Raporları';
    } else if (widget.pageType == 'sent') {
      appBarTitle = 'Gönderilen Gider Raporları';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: widget.pageType == 'sent'
              ? const TextStyle(color: Colors.white)
              : null,
        ),
        backgroundColor: mainColor,
        elevation: 0,
        iconTheme: widget.pageType == 'sent'
            ? const IconThemeData(color: Colors.white)
            : null,
      ),
      body: _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    size: 90,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Henüz bir gider raporu oluşturmadınız.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Yeni bir rapor eklemek için\n+ simgesine dokunun.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = _reports[index];
                final total = report.totalAmount;
                return report.status == ExpenseReportStatus.created
                    ? Slidable(
                        key: ValueKey(report.name),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _deleteReport(report);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Sil',
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            title: Text(
                              report.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Toplam: ${total.toStringAsFixed(2)} ₺'),
                                Text(
                                  report.status == ExpenseReportStatus.created
                                      ? 'Gönderilmedi'
                                      : 'Gönderildi',
                                  style: TextStyle(
                                    color:
                                        report.status ==
                                            ExpenseReportStatus.created
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            trailing:
                                report.status == ExpenseReportStatus.created
                                ? TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddExpense3Page(
                                            reportName: report.name,
                                            expenses: report.expenses.map((e) => e.toMap()).toList(),
                                            totalAmount: report.totalAmount,
                                            category: report.category,
                                          ),
                                        ),
                                      ).then((result) {
                                        if (result is ExpenseReport) {
                                          Navigator.pop(context, result);
                                        }
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFF57A20),
                                    ),
                                    child: const Text(
                                      'Düzenle',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ExpenseReportDetailPage(
                                                report: report,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                            onTap: () {
                              if (report.status == ExpenseReportStatus.sent) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ExpenseReportDetailPage(report: report),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Bu rapor henüz gönderilmediği için detayı görüntülenemez.',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      )
                    : Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            report.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Toplam: ${total.toStringAsFixed(2)} ₺'),
                              Text(
                                report.status == ExpenseReportStatus.created
                                    ? 'Gönderilmedi'
                                    : 'Gönderildi',
                                style: TextStyle(
                                  color:
                                      report.status ==
                                          ExpenseReportStatus.created
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          trailing: report.status == ExpenseReportStatus.created
                              ? TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddExpense3Page(
                                          reportName: report.name,
                                          expenses: report.expenses.map((e) => e.toMap()).toList(),
                                          totalAmount: report.totalAmount,
                                          category: report.category,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result is ExpenseReport) {
                                        Navigator.pop(context, result);
                                      }
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFF57A20),
                                  ),
                                  child: const Text(
                                    'Düzenle',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExpenseReportDetailPage(
                                          report: report,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          onTap: () {
                            if (report.status == ExpenseReportStatus.sent) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExpenseReportDetailPage(report: report),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bu rapor henüz gönderilmediği için detayı görüntülenemez.',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                        ),
                      );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final reportName = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => AddExpense1Page()),
          );
          if (reportName != null && reportName.isNotEmpty) {
            final firstExpense = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (_) => AddExpense2Page(reportName: reportName),
              ),
            );
            if (firstExpense != null) {
              final report = await Navigator.push<ExpenseReport>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpense3Page(
                    reportName: reportName,
                    expenses: [firstExpense],
                    totalAmount: firstExpense['amount'] as double,
                    category: firstExpense['category'] ?? '',
                  ),
                ),
              );
              if (report != null) {
                Navigator.pop(context, report);
              }
            }
          }
        },
        backgroundColor: mainColor,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
        tooltip: 'Yeni gider raporu ekle',
      ),
    );
  }
}
