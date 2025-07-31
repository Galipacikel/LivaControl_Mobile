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

  // Tasarım sistemi renkleri
  final Color mainColor = const Color(0xFFF57A20);
  final Color secondaryColor = const Color(0xFF2C2B5B);
  final Color bgColor = const Color(0xFFF6F2FF);

  // Arama ve filtreleme için state
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  List<ExpenseReportStatus> _selectedStatuses = [];
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _amountRange = const RangeValues(0, 10000);

  List<ExpenseReport> _filterByCategory(String category) {
    return widget.allReports.where((r) => r.category == category).toList();
  }

  List<ExpenseReport> _getFilteredReports() {
    List<ExpenseReport> filtered = widget.allReports;

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((report) =>
        report.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        report.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (report.expenses.isNotEmpty && 
         report.expenses.first.desc.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    // Kategori filtresi
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((report) => 
        _selectedCategories.contains(report.category)
      ).toList();
    }

    // Durum filtresi
    if (_selectedStatuses.isNotEmpty) {
      filtered = filtered.where((report) => 
        _selectedStatuses.contains(report.status)
      ).toList();
    }

    // Tarih filtresi
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((report) {
        if (report.expenses.isEmpty) return false;
        final reportDate = report.expenses.first.date;
        if (_startDate != null && reportDate.isBefore(_startDate!)) return false;
        if (_endDate != null && reportDate.isAfter(_endDate!)) return false;
        return true;
      }).toList();
    }

    // Tutar filtresi
    filtered = filtered.where((report) {
      final amount = report.totalAmount;
      return amount >= _amountRange.start && amount <= _amountRange.end;
    }).toList();

    return filtered;
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtreleme',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategories.clear();
                                _selectedStatuses.clear();
                                _startDate = null;
                                _endDate = null;
                                _amountRange = const RangeValues(0, 10000);
                              });
                            },
                            child: const Text(
                              'Temizle',
                              style: TextStyle(
                                color: Colors.red,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              this.setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Uygula',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Kategori filtresi
                  const Text(
                    'Kategoriler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: categories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontFamily: 'Inter',
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: mainColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Durum filtresi
                  const Text(
                    'Durumlar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text(
                          'Bekliyor',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
                        selected: _selectedStatuses.contains(ExpenseReportStatus.sent),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStatuses.add(ExpenseReportStatus.sent);
                            } else {
                              _selectedStatuses.remove(ExpenseReportStatus.sent);
                            }
                          });
                        },
                        backgroundColor: Colors.orange.shade100,
                        selectedColor: Colors.orange,
                      ),
                      FilterChip(
                        label: const Text(
                          'Onaylandı',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
                        selected: _selectedStatuses.contains(ExpenseReportStatus.approved),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStatuses.add(ExpenseReportStatus.approved);
                            } else {
                              _selectedStatuses.remove(ExpenseReportStatus.approved);
                            }
                          });
                        },
                        backgroundColor: Colors.green.shade100,
                        selectedColor: Colors.green,
                      ),
                      FilterChip(
                        label: const Text(
                          'Reddedildi',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
                        selected: _selectedStatuses.contains(ExpenseReportStatus.rejected),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStatuses.add(ExpenseReportStatus.rejected);
                            } else {
                              _selectedStatuses.remove(ExpenseReportStatus.rejected);
                            }
                          });
                        },
                        backgroundColor: Colors.red.shade100,
                        selectedColor: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tutar aralığı
                  const Text(
                    'Tutar Aralığı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _amountRange,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    labels: RangeLabels(
                      '₺${_amountRange.start.round()}',
                      '₺${_amountRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _amountRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tarih aralığı
                  const Text(
                    'Tarih Aralığı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDate == null 
                                ? 'Başlangıç' 
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                            style: const TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                      ),
                      const Text(' - ', style: TextStyle(fontFamily: 'Inter')),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _endDate == null 
                                ? 'Bitiş' 
                                : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                            style: const TextStyle(fontFamily: 'Inter'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    final filteredReports = _getFilteredReports();
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Admin Paneli',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Masraf ara...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontFamily: 'Inter',
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: _showFilterModal,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Filtre bilgisi
          if (_searchQuery.isNotEmpty || _selectedCategories.isNotEmpty || 
              _selectedStatuses.isNotEmpty || _startDate != null || _endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: mainColor),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredReports.length} sonuç bulundu',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategories.clear();
                        _selectedStatuses.clear();
                        _startDate = null;
                        _endDate = null;
                        _amountRange = const RangeValues(0, 10000);
                      });
                    },
                    child: Text(
                      'Temizle',
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Liste
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: categories.map((category) {
                final categoryReports = filteredReports.where((r) => r.category == category).toList();
                if (categoryReports.isEmpty) return const SizedBox.shrink();
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
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
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: mainColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            categoryReports.length.toString(),
                            style: TextStyle(
                              color: mainColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    initiallyExpanded: categoryReports.isNotEmpty,
                    children: categoryReports.map((report) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            report.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (report.expenses.isNotEmpty)
                                Text(
                                  report.expenses.first.desc,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Tutar: ${report.totalAmount.toStringAsFixed(2)} ₺',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(report.status).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(report.status),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getStatusText(report.status),
                              style: TextStyle(
                                color: _getStatusColor(report.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
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
          ),
        ],
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
        return mainColor;
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
  // Tasarım sistemi renkleri
  final Color mainColor = const Color(0xFFF57A20);
  final Color secondaryColor = const Color(0xFF2C2B5B);
  final Color bgColor = const Color(0xFFF6F2FF);

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final bool isAlreadyProcessed = report.status == ExpenseReportStatus.approved || 
                                   report.status == ExpenseReportStatus.rejected;
    final expense = report.expenses.isNotEmpty ? report.expenses.first : null;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Masraf Detayı',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
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
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expense.rejectionReason!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Ekli makbuz
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ekli Makbuz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: expense != null && expense.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
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
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Durum mesajı (eğer zaten işlenmişse)
            if (isAlreadyProcessed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: report.status == ExpenseReportStatus.approved 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
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
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Onayla/Reddet butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAlreadyProcessed ? Colors.grey : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAlreadyProcessed ? Colors.grey : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Reddetme nedenini belirtin',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                                fontFamily: 'Inter',
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
                                          fontFamily: 'Inter',
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(16),
                                        counterStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontFamily: 'Inter',
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
                                              fontFamily: 'Inter',
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
                                              fontFamily: 'Inter',
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
                                const Text(
                                  'Masraf reddedildi',
                                  style: TextStyle(fontFamily: 'Inter'),
                                ),
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
                        fontFamily: 'Inter',
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
              fontFamily: 'Inter',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: 'Inter',
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
    // Tasarım sistemi renkleri
    final Color mainColor = const Color(0xFFF57A20);
    final Color secondaryColor = const Color(0xFF2C2B5B);
    final Color bgColor = const Color(0xFFF6F2FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Sonuç',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Şirket Adı', report.name),
                  _buildDetailRow('Durumu', isApproved ? 'Onaylandı' : 'Reddedildi'),
                  _buildDetailRow('Değer', '${report.totalAmount.toStringAsFixed(2)} ₺'),
                  _buildDetailRow('Tarih', _formatDate(DateTime.now())),
                  _buildDetailRow('Açıklama', report.expenses.isNotEmpty ? report.expenses.first.desc : ''),
                  _buildDetailRow('Kategori', report.category),
                  _buildDetailRow('KDV Vergisi', '10'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Ekli makbuz
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ekli Makbuz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: report.expenses.isNotEmpty && report.expenses.first.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
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
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Sonuç mesajı
            if (isApproved) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
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
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
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
                            fontFamily: 'Inter',
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
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Ana sayfaya dön butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                    fontFamily: 'Inter',
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
              fontFamily: 'Inter',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: 'Inter',
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
