import 'package:flutter/material.dart';
import '../models/expense_report.dart';
import 'all_expenses_page.dart';
import 'expense_report_detail_page.dart';
import '../Chat/chat_main_page.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import '../admin/admin_panel_page.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../add_expenses/add_expense3.dart';

class HomePage extends StatefulWidget {
  final String username;
  final List<ExpenseReport> reports;
  final void Function(ExpenseReport) onAddReport;
  final void Function(ExpenseReport) onUpdateReport;
  final VoidCallback onLogout;
  final VoidCallback onGoToSettings;

  const HomePage({
    super.key,
    required this.username,
    required this.reports,
    required this.onAddReport,
    required this.onUpdateReport,
    required this.onLogout,
    required this.onGoToSettings,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? profileImagePath; // null ise placeholder göster
  String get userInitials => widget.username.isNotEmpty
      ? widget.username
            .trim()
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
      : '';



  @override
  Widget build(BuildContext context) {
    String searchQuery = '';
    final created = widget.reports
        .where((r) => r.status == ExpenseReportStatus.created)
        .toList();
    final sent = widget.reports
        .where((r) => r.status == ExpenseReportStatus.sent)
        .toList();
    List<ExpenseReport> filteredReports = widget.reports;

    final user = Provider.of<SessionProvider>(context).currentUser;
    final isAdmin = user != null && user.role == 'admin';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF57A20), Color(0xFF2C2B5B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ana Sayfa',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    tooltip: 'Sohbet',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatMainPage()),
                      );
                    },
                  ),
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'Admin Paneli',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminPanelPage(
                              allReports: widget.reports,
                              onStatusChanged: (updatedReport) {
                                final idx = widget.reports.indexWhere(
                                  (r) => r.name == updatedReport.name,
                                );
                                if (idx >= 0) {
                                  setState(() {
                                    widget.reports[idx] = updatedReport;
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      // drawer: Drawer(...), // Drawer'ı tamamen kaldırdım
      body: SafeArea(
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İstatistik kartları
                    Row(
                      children: [
                        _StatCard(
                          title: 'Gider raporu\nolusturuldu',
                          count: created.length,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AllExpensesPage(
                                  reports: created,
                                  pageType: 'created',
                                ),
                              ),
                            ).then((result) {
                              if (result is ExpenseReport) {
                                setState(() {
                                  widget.reports.removeWhere(
                                    (r) => r.name == result.name,
                                  );
                                });
                              }
                            });
                          },
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF57A20), Color(0xFFFFA040)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _StatCard(
                          title: 'Gider raporu\ngönderildi',
                          count: sent.length,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AllExpensesPage(
                                  reports: sent,
                                  pageType: 'sent',
                                ),
                              ),
                            ).then((result) {
                              if (result is ExpenseReport) {
                                setState(() {
                                  widget.reports.removeWhere(
                                    (r) => r.name == result.name,
                                  );
                                });
                              }
                            });
                          },
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2C2B5B), Color(0xFF3A3472)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Son Gider Raporları başlığı ve tümünü gör
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Son Gider Raporları',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AllExpensesPage(
                                  reports: widget.reports,
                                  pageType: 'created',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Tümünü gör',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFF57A20),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Arama kutusu
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                            filteredReports = widget.reports
                                .where(
                                  (r) => r.name.toLowerCase().contains(
                                    searchQuery.toLowerCase(),
                                  ),
                                )
                                .toList();
                          });
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFFB0ADAD),
                          ),
                          hintText: 'Ara',
                          hintStyle: TextStyle(
                            color: Color(0xFFB0ADAD),
                            fontFamily: 'Inter',
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Gider kartları
                    ...filteredReports.isEmpty
                        ? [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: Text(
                                  'Gider raporu bulunamadı!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withValues(alpha: 0.7),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),
                          ]
                        : filteredReports
                              .take(4)
                              .map(
                                (report) => _ExpenseCard(
                                  report: report,
                                  onDetail: () {
                                    if (report.status ==
                                        ExpenseReportStatus.sent) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ExpenseReportDetailPage(
                                                report: report,
                                              ),
                                        ),
                                      );
                                    } else {
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
                                          widget.onUpdateReport(result);
                                        }
                                      });
                                    }
                                  },
                                  onDelete:
                                      report.status ==
                                          ExpenseReportStatus.created
                                      ? () {
                                          setState(() {
                                            widget.reports.removeWhere(
                                              (r) => r.name == report.name,
                                            );
                                          });
                                        }
                                      : null,
                                ),
                              )
                              .toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onTap;
  final Gradient gradient;

  const _StatCard({
    required this.title,
    required this.count,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseReport report;
  final VoidCallback onDetail;
  final VoidCallback? onDelete; // Silme fonksiyonu

  const _ExpenseCard({
    required this.report,
    required this.onDetail,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCreated = report.status == ExpenseReportStatus.created;
    final bool isSent = report.status == ExpenseReportStatus.sent;
    final String statusText = isSent ? 'Gönderildi' : 'Oluşturuldu';
    final Color statusColor = isSent
        ? Colors.green.shade100
        : Colors.grey.shade200;
    final Color statusTextColor = isSent
        ? Colors.green.shade800
        : Colors.grey.shade700;

    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    report.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusTextColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${report.totalAmount.toStringAsFixed(2)} GBP',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${report.expenses.length} gider',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: onDetail,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFF57A20),
            ),
            child: Text(
              report.status == ExpenseReportStatus.created
                  ? 'Düzenle'
                  : 'Detaylar',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );

    if (isCreated && onDelete != null) {
      return Slidable(
        key: ValueKey(report.name),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onDelete!(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Sil',
            ),
          ],
        ),
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }
}


