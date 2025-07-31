enum ExpenseReportStatus { created, sent, approved, rejected }

///Gider raporu modeli.

// Gider kalemi modeli (map yerine class)
class ExpenseItem {
  final String vendor;
  final double amount;
  final String desc;
  final DateTime date;
  final String category;
  ExpenseReportStatus status;

  ExpenseItem({
    required this.vendor,
    required this.amount,
    required this.desc,
    required this.date,
    required this.category,
    this.status = ExpenseReportStatus.sent,
  });

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      vendor: map['vendor'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      desc: map['desc'] ?? '',
      date: map['date'] ?? DateTime.now(),
      category: map['category'] ?? '',
      status: map['status'] != null
          ? ExpenseReportStatus.values.firstWhere(
              (e) => e.toString().split('.').last == map['status'],
              orElse: () => ExpenseReportStatus.sent,
            )
          : ExpenseReportStatus.sent,
    );
  }

  Map<String, dynamic> toMap() => {
    'vendor': vendor,
    'amount': amount,
    'desc': desc,
    'date': date,
    'category': category,
    'status': status.toString().split('.').last,
  };
}

class ExpenseReport {
  final String id;
  final String name;
  final ExpenseReportStatus status;
  final List<ExpenseItem> expenses;
  final double totalAmount;
  final String category; // Kategori bilgisi eklendi

  ExpenseReport({
    required this.id,
    required this.name,
    required this.status,
    required this.expenses,
    required this.totalAmount,
    required this.category,
  });
}
