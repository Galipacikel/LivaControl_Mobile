import 'package:flutter/material.dart';

class AddExpense1Page extends StatefulWidget {
  const AddExpense1Page({super.key});

  @override
  State<AddExpense1Page> createState() => _AddExpense1PageState();
}

class _AddExpense1PageState extends State<AddExpense1Page> {
  final TextEditingController _reportNameController = TextEditingController();

  @override
  void dispose() {
    _reportNameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_reportNameController.text.isEmpty) return;
    Navigator.of(context).pop(_reportNameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (BuildContext newContext) {
          final size = MediaQuery.of(newContext).size;
          final isSmallScreen = size.width < 400;
          final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
          final titleFontSize = size.width < 350 ? 14.0 : 16.0;
          final inputFontSize = size.width < 350 ? 12.0 : 14.0;
          final buttonFontSize = size.width < 350 ? 14.0 : 16.0;


          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst bar ve başlık
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Gider Kaydı Oluştur',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),
                  // Rapor Adı
                  Text(
                    'Gider Kayıt Adı',
                    style: TextStyle(
                      fontSize: inputFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: TextField(
                      controller: _reportNameController,
                      style: TextStyle(fontSize: inputFontSize),
                      decoration: const InputDecoration(
                        hintText: 'Gider Kaydı giriniz',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Gider Ekle Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57A20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _continue,
                      child: Text(
                        'Devam Et',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Submit Expense Report Butonu (pasif)
                  Opacity(
                    opacity: 0.4,
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC4C4C4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: null,
                        child: Text(
                          'Gider Kaydı Gönder',
                          style: TextStyle(
                            fontSize: buttonFontSize,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
