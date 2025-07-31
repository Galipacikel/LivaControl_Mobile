import 'package:flutter/material.dart';

// Switch durumunu global olarak tanımla
bool globalInstantNotification = false;

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late bool instantNotification;

  @override
  void initState() {
    super.initState();
    instantNotification = globalInstantNotification;
  }

  void _updateGlobalState() {
    globalInstantNotification = instantNotification;
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFFF57A20); // Uygulamanın ana rengi
    final Color secondaryColor = const Color(0xFF2C2B5B); // Tamamlayıcı renk
    final Color borderColor = const Color(0xFFF57A20).withValues(alpha: 0.4);
    final Color bgColor = Colors.white;

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
                    'Bildirimi Ayarla',
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
            const Text(
              'Gider taleplerinizle ilgili güncellemeleri anında almak için bildirimi açabilirsiniz.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: mainColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.notifications_active, color: mainColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Anında Bildirim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gider taleplerinizle ilgili güncellemeleri anında alın.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: instantNotification,
                    activeColor: mainColor,
                    onChanged: (val) => setState(() => instantNotification = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 