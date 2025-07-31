import 'package:flutter/material.dart';
import '../models/expense_report.dart';

class AdminPanelPage extends StatefulWidget {
  final List<ExpenseReport> allReports;
  final void Function(ExpenseReport updatedReport)? onStatusChanged;
  const AdminPanelPage({
    super.key,
    required this.allReports,
    this.onStatusChanged,
  });

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = [
    'Satın Alımlar',
    'Sipariş',
    'Stoktan Malzeme Talepleri',
    'Masraflar',
    'Ek Bütçe',
    'Transfer Bütçe',
    'Avans ve Ödeme Talepleri',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ExpenseReport> _filterByStatus(ExpenseReportStatus status) {
    return widget.allReports.where((r) => r.status == status).toList();
  }

  List<ExpenseReport> _filterByCategory(
    List<ExpenseReport> reports,
    String category,
  ) {
    return reports.where((r) => r.category == category).toList();
  }

  void _changeStatus(ExpenseReport report, ExpenseReportStatus newStatus) {
    setState(() {
      final idx = widget.allReports.indexWhere((r) => r.name == report.name);
      if (idx != -1) {
        widget.allReports[idx] = ExpenseReport(
          id: report.id,
          name: report.name,
          status: newStatus,
          expenses: report.expenses,
          totalAmount: report.totalAmount,
          category: report.category,
        );
      }
    });
    if (widget.onStatusChanged != null) {
      widget.onStatusChanged!(
        ExpenseReport(
          id: report.id,
          name: report.name,
          status: newStatus,
          expenses: report.expenses,
          totalAmount: report.totalAmount,
          category: report.category,
        ),
      );
    }
    // TODO: API çağrısı burada yapılacak
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

  void _showReportDetailModal(
    BuildContext context,
    ExpenseReport report,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              double approvedTotal = report.expenses
                  .where((e) => e.status == ExpenseReportStatus.approved)
                  .fold(0, (sum, e) => sum + e.amount);
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kategori: ${report.category}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Onaylanan Toplam:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${approvedTotal.toStringAsFixed(2)} ₺',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: report.expenses.asMap().entries.map((entry) {
                            final exp = entry.value;
                            Color statusColor;
                            String statusText;
                            switch (exp.status) {
                              case ExpenseReportStatus.approved:
                                statusColor = Colors.green;
                                statusText = 'Onaylandı';
                                break;
                              case ExpenseReportStatus.rejected:
                                statusColor = Colors.red;
                                statusText = 'Reddedildi';
                                break;
                              case ExpenseReportStatus.sent:
                                statusColor = const Color(0xFFF57A20);
                                statusText = 'Bekliyor';
                                break;
                              default:
                                statusColor = Colors.grey;
                                statusText = 'Bilinmiyor';
                            }
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  exp.desc,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tutar: ${exp.amount.toStringAsFixed(2)} ₺'),
                                    Text('Satıcı: ${exp.vendor}'),
                                    Text(
                                      'Tarih: ${exp.date.day.toString().padLeft(2, '0')}/${exp.date.month.toString().padLeft(2, '0')}/${exp.date.year}',
                                    ),
                                    Text('Kategori: ${exp.category}'),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (exp.status == ExpenseReportStatus.sent) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                exp.status =
                                                    ExpenseReportStatus.approved;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                exp.status =
                                                    ExpenseReportStatus.rejected;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () {
                                  // Gider kalemi detay modalı açılabilir
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57A20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Kapat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryPanel(
    List<ExpenseReport> reports, {
    bool showActions = false,
  }) {
    final badgeColors = [
      Colors.orange.shade100,
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.green.shade100,
      Colors.teal.shade100,
      Colors.red.shade100,
      Colors.amber.shade100,
    ];
    return ListView(
      children: categories.asMap().entries.map((entry) {
        final i = entry.key;
        final cat = entry.value;
        final catReports = _filterByCategory(reports, cat);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    cat,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (catReports.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColors[i % badgeColors.length],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      catReports.length.toString(),
                      style: const TextStyle(
                        color: Color(0xFFF57A20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            initiallyExpanded: catReports.isNotEmpty,
            children: catReports.isEmpty
                ? [
                    const ListTile(
                      title: Text(
                        'Kayıt yok',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ]
                : catReports.map((report) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Text(
                          report.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (report.expenses.isNotEmpty)
                              Text(
                                report.expenses.first.desc,
                                style: const TextStyle(fontSize: 13),
                              ),
                            Text(
                              'Tutar: ${report.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        trailing: showActions
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Onayla',
                                    onPressed: () => _changeStatus(
                                      report,
                                      ExpenseReportStatus.approved,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Reddet',
                                    onPressed: () => _changeStatus(
                                      report,
                                      ExpenseReportStatus.rejected,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                        onTap: () async {
                          _showReportDetailModal(context, report);
                        },
                      ),
                    );
                  }).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Paneli'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFF57A20),
            unselectedLabelColor: Colors.black54,
            indicatorColor: const Color(0xFFF57A20),
            tabs: const [
              Tab(text: 'Onay Bekleyenler'),
              Tab(text: 'Onaylananlar'),
              Tab(text: 'Reddedilenler'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCategoryPanel(
              _filterByStatus(ExpenseReportStatus.sent),
              showActions: true,
            ),
            _buildCategoryPanel(_filterByStatus(ExpenseReportStatus.approved)),
            _buildCategoryPanel(_filterByStatus(ExpenseReportStatus.rejected)),
          ],
        ),
      ),
    );
  }
}
