import 'package:flutter/material.dart';
import 'package:counter/utils/colors.dart';
class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar(this.onIndexChanged,{super.key});
  final Function(int) onIndexChanged;
  @override
  State<MainBottomNavigationBar> createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child:BottomNavigationBar( onTap: (int index) {
            setState(() {
              currentPageIndex = index;
            });
            widget.onIndexChanged(index);
          },
          backgroundColor: Colors.transparent,
          currentIndex: currentPageIndex,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColorTemplate.lightBlue,
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: "Home"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.phone_outlined),
                  label: "Contact"
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_hospital_outlined),
                  label: "Clinics"
                ),
            ]
          ),
      ),
    );
  }
}