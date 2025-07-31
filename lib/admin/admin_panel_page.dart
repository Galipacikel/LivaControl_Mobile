import 'package:flutter/material.dart';
import '../models/expense_report.dart';
import 'dart:io';

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

class _AdminPanelPageState extends State<AdminPanelPage> {
  final List<String> categories = [
    'Satın Alımlar',
    'Sipariş',
    'Stoktan Malzeme Talepleri',
    'Masraflar',
    'Ek Bütçe',
    'Transfer Bütçe',
    'Avans ve Ödeme Talepleri',
  ];

  List<ExpenseReport> _filterByCategory(String category) {
    return widget.allReports.where((r) => r.category == category).toList();
  }

  void _changeStatus(ExpenseReport report, ExpenseReportStatus newStatus, {String? rejectionReason}) {
    setState(() {
      final idx = widget.allReports.indexWhere((r) => r.name == report.name);
      if (idx != -1) {
        // Eğer reddedildiyse, ilk masrafın rejectionReason'ını güncelle
        final updatedExpenses = report.expenses.map((e) {
          if (newStatus == ExpenseReportStatus.rejected && e == report.expenses.first) {
            return ExpenseItem(
              vendor: e.vendor,
              amount: e.amount,
              desc: e.desc,
              date: e.date,
              category: e.category,
              imagePath: e.imagePath,
              status: ExpenseReportStatus.rejected,
              rejectionReason: rejectionReason,
            );
          } else {
            return e;
          }
        }).toList();
        widget.allReports[idx] = ExpenseReport(
          id: report.id,
          name: report.name,
          status: newStatus,
          expenses: updatedExpenses,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: categories.map((category) {
          final categoryReports = _filterByCategory(category);
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
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (categoryReports.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categoryReports.length.toString(),
                        style: const TextStyle(
                          color: Color(0xFFF57A20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              initiallyExpanded: categoryReports.isNotEmpty,
              children: categoryReports.isEmpty
                  ? [
                      const ListTile(
                        title: Text(
                          'Kayıt yok',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ]
                  : categoryReports.map((report) {
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
                                'Tutar: ${report.totalAmount.toStringAsFixed(2)} ₺',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(report.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(report.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpenseDetailPage(
                                  report: report,
                                  onStatusChanged: _changeStatus,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(ExpenseReportStatus status) {
    switch (status) {
      case ExpenseReportStatus.approved:
        return Colors.green;
      case ExpenseReportStatus.rejected:
        return Colors.red;
      case ExpenseReportStatus.sent:
        return const Color(0xFFF57A20);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(ExpenseReportStatus status) {
    switch (status) {
      case ExpenseReportStatus.approved:
        return 'Onaylandı';
      case ExpenseReportStatus.rejected:
        return 'Reddedildi';
      case ExpenseReportStatus.sent:
        return 'Bekliyor';
      default:
        return 'Bilinmiyor';
    }
  }
}

class ExpenseDetailPage extends StatefulWidget {
  final ExpenseReport report;
  final void Function(ExpenseReport, ExpenseReportStatus, {String? rejectionReason}) onStatusChanged;

  const ExpenseDetailPage({
    super.key,
    required this.report,
    required this.onStatusChanged,
  });

  @override
  State<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final bool isAlreadyProcessed = report.status == ExpenseReportStatus.approved || 
                                   report.status == ExpenseReportStatus.rejected;
    final expense = report.expenses.isNotEmpty ? report.expenses.first : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masraf Detayı'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              report.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Şirket Adı', report.name),
            _buildDetailRow('Durumu', _getStatusText(report.status)),
            _buildDetailRow('Değer', '${report.totalAmount.toStringAsFixed(2)} ₺'),
            _buildDetailRow('Tarih', _formatDate(DateTime.now())),
            _buildDetailRow('Açıklama', expense?.desc ?? ''),
            _buildDetailRow('Kategori', report.category),
            _buildDetailRow('KDV Vergisi', '10'),
            if (expense?.rejectionReason != null && expense!.rejectionReason!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reddedilme Nedeni',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expense.rejectionReason!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Ekli Makbuz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: expense != null && expense.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(expense.imagePath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Makbuz görseli yok',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            if (isAlreadyProcessed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: report.status == ExpenseReportStatus.approved 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: report.status == ExpenseReportStatus.approved 
                        ? Colors.green.shade200 
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      report.status == ExpenseReportStatus.approved 
                          ? Icons.check_circle 
                          : Icons.cancel,
                      color: report.status == ExpenseReportStatus.approved 
                          ? Colors.green 
                          : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      report.status == ExpenseReportStatus.approved 
                          ? 'Bu masraf zaten onaylanmış'
                          : 'Bu masraf zaten reddedilmiş',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: report.status == ExpenseReportStatus.approved 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAlreadyProcessed ? Colors.grey : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isAlreadyProcessed ? null : () {
                      try {
                        widget.onStatusChanged(report, ExpenseReportStatus.approved);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApprovalResultPage(
                              report: report,
                              isApproved: true,
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Onayla',
                      style: TextStyle(
                        color: isAlreadyProcessed ? Colors.grey.shade600 : Colors.white,
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
                      backgroundColor: isAlreadyProcessed ? Colors.grey : Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isAlreadyProcessed ? null : () async {
                      final reason = await showDialog<String>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          String? inputReason;
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Masrafı Reddet',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Reddetme nedenini belirtin',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Input Field
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextField(
                                      autofocus: true,
                                      maxLines: 4,
                                      minLines: 3,
                                      maxLength: 200,
                                      decoration: InputDecoration(
                                        hintText: 'Reddetme nedenini detaylı olarak yazınız...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(16),
                                        counterStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      onChanged: (value) => inputReason = value,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'İptal',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (inputReason != null && inputReason!.trim().isNotEmpty) {
                                              Navigator.pop(context, inputReason!.trim());
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            'Reddet',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      if (reason != null && reason.trim().isNotEmpty) {
                        widget.onStatusChanged(report, ExpenseReportStatus.rejected, rejectionReason: reason.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20),
                                const SizedBox(width: 12),
                                const Text('Masraf reddedildi'),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApprovalResultPage(
                              report: report,
                              isApproved: false,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Reddet',
                      style: TextStyle(
                        color: isAlreadyProcessed ? Colors.grey.shade600 : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusText(ExpenseReportStatus status) {
    switch (status) {
      case ExpenseReportStatus.approved:
        return 'Onaylandı';
      case ExpenseReportStatus.rejected:
        return 'Reddedildi';
      case ExpenseReportStatus.sent:
        return 'Bekliyor';
      default:
        return 'Bilinmiyor';
    }
  }
}

class ApprovalResultPage extends StatelessWidget {
  final ExpenseReport report;
  final bool isApproved;

  const ApprovalResultPage({
    super.key,
    required this.report,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonuç'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              report.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Detaylar
            _buildDetailRow('Şirket Adı', report.name),
            _buildDetailRow('Durumu', isApproved ? 'Onaylandı' : 'Reddedildi'),
            _buildDetailRow('Değer', '${report.totalAmount.toStringAsFixed(2)} ₺'),
            _buildDetailRow('Tarih', _formatDate(DateTime.now())),
            _buildDetailRow('Açıklama', report.expenses.isNotEmpty ? report.expenses.first.desc : ''),
            _buildDetailRow('Kategori', report.category),
            _buildDetailRow('KDV Vergisi', '10'),
            
            const SizedBox(height: 24),
            
            // Ekli makbuz
            const Text(
              'Ekli Makbuz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: report.expenses.isNotEmpty && report.expenses.first.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(report.expenses.first.imagePath!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Makbuz görseli yok',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Sonuç mesajı
            if (isApproved) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Onaylandı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Reddedildi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (report.expenses.isNotEmpty && 
                        report.expenses.first.rejectionReason != null && 
                        report.expenses.first.rejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        report.expenses.first.rejectionReason!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Ana sayfaya dön butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57A20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'Ana Sayfaya Dön',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
