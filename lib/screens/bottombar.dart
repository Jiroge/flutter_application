import 'package:flutter/material.dart';
import 'package:flutter_application/config.dart';
import 'package:flutter_application/shared/cart_notifier.dart';
import 'package:flutter_application/screens/screen_index.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  final Set<int> hiddenBottomBarScreens = {1};

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    cartItemCount.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    cartItemCount.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  Widget _buildIcon(IconData iconData, int index) {
    bool isSelected = _selectedIndex == index;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isSelected)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MainColors.secondaryColor, 
              shape: BoxShape.circle,
            ),
          ),
        Icon(
          iconData,
          color: isSelected ? Colors.black : Colors.grey,
          size: isSelected ? 30 : 24, 
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: bottombarScreenOptions(onBackToHome: () {
        setState(() {
          _selectedIndex = 0;
        });
      })[_selectedIndex],
      bottomNavigationBar: hiddenBottomBarScreens.contains(_selectedIndex)
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.stars_rounded, 0),
                  label: 'Shopping',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildIcon(Icons.stars_outlined, 1),
                    ],
                  ),
                  label:
                      'Cart ${cartItemCount.value > 0 ? "(${cartItemCount.value})" : ""}',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black,
              onTap: _onItemTapped,
            ),
    );
  }
}
