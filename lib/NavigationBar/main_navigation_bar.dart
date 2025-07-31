import 'package:flutter/material.dart';

class MainNavigationBar extends StatelessWidget {
  final VoidCallback? onHome;
  final VoidCallback? onAdd;
  final VoidCallback? onSettings;
  final int currentIndex;
  const MainNavigationBar({
    super.key,
    this.onHome,
    this.onAdd,
    this.onSettings,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 8,
      color: Colors.white,
      child: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavBarItem(
                icon: Icons.home,
                label: 'Ana Sayfa',
                isActive: currentIndex == 0,
                onTap: onHome,
              ),
              // Ortadaki + buton için boşluk (FAB HomePage'de olacak)
              const SizedBox(width: 56),
              _NavBarItem(
                icon: Icons.settings,
                label: 'Ayarlar',
                isActive: currentIndex == 1,
                onTap: onSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFF37021) : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? const Color(0xFFF37021) : Colors.grey,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
