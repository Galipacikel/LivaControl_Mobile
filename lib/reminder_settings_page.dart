import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Switch durumlarını global olarak tanımla
bool globalDaily = false;
bool globalWeekly = false;
bool globalMonthly = false;
String? globalCustomDate;
bool globalCustomDateEnabled = false;
String? globalCustomDescription;

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({Key? key}) : super(key: key);

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  late bool daily;
  late bool weekly;
  late bool monthly;
  DateTime? customDate;
  bool customDateEnabled = false;
  String? customDescription;

  @override
  void initState() {
    super.initState();
    daily = globalDaily;
    weekly = globalWeekly;
    monthly = globalMonthly;
    customDate = globalCustomDate != null ? DateFormat('dd/MM/yyyy').parse(globalCustomDate!) : null;
    customDateEnabled = globalCustomDateEnabled;
    customDescription = globalCustomDescription;
  }

  void _updateGlobalState() {
    globalDaily = daily;
    globalWeekly = weekly;
    globalMonthly = monthly;
    globalCustomDate = customDate != null ? DateFormat('dd/MM/yyyy').format(customDate!) : null;
    globalCustomDateEnabled = customDateEnabled;
    globalCustomDescription = customDescription;
  }

  Future<void> _addCustomReminder() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 5),
      helpText: 'Tarih Seç',
      locale: const Locale('tr'),
    );
    if (pickedDate != null) {
      final desc = await showDialog<String>(
        context: context,
        builder: (context) => _CustomDescriptionDialog(),
      );
      if (desc != null && desc.trim().isNotEmpty) {
        setState(() {
          customDate = pickedDate;
          customDateEnabled = true;
          customDescription = desc.trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFFF57A20); // Uygulamanın ana rengi
    final Color secondaryColor = const Color(0xFF2C2B5B); // Tamamlayıcı renk

    final Color bgColor = const Color(0xFFF6F2FF); // Hafif morumsu arka plan

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
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      _updateGlobalState();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Hatırlatıcı Ayarla',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReminderCard(
              icon: Icons.calendar_today,
              iconColor: secondaryColor,
              title: 'Günlük Hatırlatıcı',
              description: 'Her gün harcama girişi için hatırlatıcı alın.',
              value: daily,
              onChanged: (val) => setState(() => daily = val),
            ),
            const SizedBox(height: 18),
            _ReminderCard(
              icon: Icons.calendar_view_week,
              iconColor: mainColor,
              title: 'Haftalık Hatırlatıcı',
              description: 'Her hafta harcama girişi için hatırlatıcı alın.',
              value: weekly,
              onChanged: (val) => setState(() => weekly = val),
            ),
            const SizedBox(height: 18),
            _ReminderCard(
              icon: Icons.calendar_view_month,
              iconColor: secondaryColor,
              title: 'Aylık Hatırlatıcı',
              description: 'Her ay harcama girişi için hatırlatıcı alın.',
              value: monthly,
              onChanged: (val) => setState(() => monthly = val),
            ),
            if (customDate != null && customDescription != null) ...[
              const SizedBox(height: 18),
              _ReminderCard(
                icon: Icons.event,
                iconColor: mainColor,
                title: DateFormat('dd MMMM yyyy', 'tr').format(customDate!),
                description: customDescription!,
                value: customDateEnabled,
                onChanged: (val) => setState(() => customDateEnabled = val),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Özel Hatırlatıcı Ekle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Inter'),
              ),
              onPressed: _addCustomReminder,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ReminderCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: const Color(0xFFF57A20),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomDescriptionDialog extends StatefulWidget {
  @override
  State<_CustomDescriptionDialog> createState() => _CustomDescriptionDialogState();
}

class _CustomDescriptionDialogState extends State<_CustomDescriptionDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Açıklama Girin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Hatırlatıcı için bir açıklama girin',
                style: TextStyle(fontSize: 15, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Açıklama',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF57A20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pop(_controller.text.trim());
                },
                child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 