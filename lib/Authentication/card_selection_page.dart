import 'package:flutter/material.dart';
import 'login_page.dart';

class CardSelectionPage extends StatelessWidget {
  const CardSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Paket Seçimi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9, // Adjust card aspect ratio
          children: [
            _buildPackageCard(
              context,
              'LivaControl',
              'assets/livacontrol_logo.png',
              true, // Active
            ),
            _buildPackageCard(
              context,
              'LivaBudget',
              'assets/livabudget.png',
              false, // Inactive
            ),
            _buildPackageCard(
              context,
              'LivaClick',
              'assets/livaclick.png',
              false, // Inactive
            ),
            _buildPackageCard(
              context,
              'LivaMRP',
              'assets/livamrp.png',
              false, // Inactive
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, String title, String imagePath, bool isActive) {
    return GestureDetector(
      onTap: isActive
          ? () {
              if (title == 'LivaControl') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(onLogin: (user) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }),
                  ),
                );
              }
            }
          : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Card(
          elevation: isActive ? 6 : 2,
          shadowColor: isActive ? const Color(0xFFF57A20).withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isActive ? const Color(0xFFF57A20) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: isActive
                  ? LinearGradient(
                      colors: [const Color(0xFFF57A20).withValues(alpha: 0.1), Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, height: 60),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (!isActive)
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Yakında',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
