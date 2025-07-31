import 'package:flutter/material.dart';
import 'card_selection_page.dart';

class KeyEntryPage extends StatefulWidget {
  const KeyEntryPage({super.key});

  @override
  State<KeyEntryPage> createState() => _KeyEntryPageState();
}

class _KeyEntryPageState extends State<KeyEntryPage> {
  final TextEditingController _keyController = TextEditingController();

  void _submitKey() {
    // For now, any key will navigate to the card selection page.
    // Key validation logic will be added later.
    if (_keyController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CardSelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    final horizontalPadding = isSmallScreen ? 24.0 : 40.0;
    final logoHeight = size.height * 0.15;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.05),
                  child: Image.asset(
                    'assets/dataliva.png',
                    height: logoHeight > 130 ? 130 : logoHeight,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                // Title
                const Text(
                  'Hoş Geldiniz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Subtitle
                const Text(
                  'Lütfen devam etmek için ürün anahtarınızı girin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: size.height * 0.06),
                // Key Input Field
                TextField(
                  controller: _keyController,
                  decoration: InputDecoration(
                    labelText: 'Ürün Anahtarı',
                    hintText: 'Anahtarınızı buraya girin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                // Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF57A20), // Orange color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: _submitKey,
                    child: const Text(
                      'Devam Et',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }
}
