import 'package:flutter/material.dart';

import '../colors.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _selectedIndex = 0;
  static const List<IconData> _icons = [
    Icons.home,
    Icons.person,
    Icons.search,
    Icons.notifications,
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      selectedIconTheme: IconThemeData(color: AppColors.pink),
      unselectedItemColor: AppColors.black,
      backgroundColor: Colors.white,
      items: List.generate(
        _icons.length,
        (index) => BottomNavigationBarItem(
          icon: _selectedIndex == index
              ? _buildSelectedIcon(index)
              : Icon(_icons[index]),
          label: '',
        ),
      ),
    );
  }

  Widget _buildSelectedIcon(int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pink,
      ),
      child: Icon(
        _icons[index],
        color: Colors.white,
      ),
    );
  }
}
