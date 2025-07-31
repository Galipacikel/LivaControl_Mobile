import 'package:flutter/material.dart';
import 'add_expense1.dart';
import 'add_expense2.dart';
import 'add_expense3.dart';

class AddExpenseChoicePage extends StatelessWidget {
  const AddExpenseChoicePage({super.key});

  final List<_ExpenseType> expenseTypes = const [
    _ExpenseType('Satın Alımlar', Icons.shopping_cart),
    _ExpenseType('Sipariş', Icons.receipt_long),
    _ExpenseType('Stoktan Malzeme Talepleri', Icons.inventory_2),
    _ExpenseType('Masraflar', Icons.attach_money),
    _ExpenseType('Ek Bütçe', Icons.add_card),
    _ExpenseType('Transfer Bütçe', Icons.swap_horiz),
    _ExpenseType('Avans ve Ödeme Talepleri', Icons.account_balance_wallet),
  ];

  void _startExpenseFlow(BuildContext context, String type) async {
    final reportName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => AddExpense1Page()),
    );
    if (reportName == null || reportName.isEmpty) return;
    final firstExpense = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpense2Page(reportName: reportName),
      ),
    );
    if (firstExpense != null) {
      final report = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddExpense3Page(
            reportName: reportName,
            expenses: [firstExpense],
            totalAmount: firstExpense['amount'] as double,
            category: type,
          ),
        ),
      );
      if (report != null) {
        Navigator.pop(context, report);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardHeight = size.height * 0.13 < 110 ? 110.0 : size.height * 0.13;
    final cardRadius = 18.0;
    final cardColor = Colors.white;
    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.07),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masraf Türü Seç'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lütfen bir masraf türü seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: expenseTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final type = expenseTypes[index];
                    return GestureDetector(
                      onTap: () => _startExpenseFlow(context, type.title),
                      child: Container(
                        height: cardHeight,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(cardRadius),
                          boxShadow: cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: cardHeight,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF57A20,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(cardRadius),
                                  bottomLeft: Radius.circular(cardRadius),
                                ),
                              ),
                              child: Icon(
                                type.icon,
                                size: 38,
                                color: const Color(0xFFF57A20),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Text(
                                type.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF28303F),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFB0ADAD),
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseType {
  final String title;
  final IconData icon;
  const _ExpenseType(this.title, this.icon);
}
