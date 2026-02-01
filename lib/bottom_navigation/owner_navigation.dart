import 'package:flutter/material.dart';
import 'package:petcare_app/owner_homescreen/owner_homescreen.dart';
import 'package:petcare_app/profile_screen/owner_profile.dart';
import 'package:petcare_app/reminders/reminder_screen.dart';
import 'package:petcare_app/vet_finder/find_clinics_screen.dart';

class OwnerNavigation extends StatefulWidget {
  const OwnerNavigation({super.key});

  @override
  State<OwnerNavigation> createState() => _OwnerNavigationState();
}

class _OwnerNavigationState extends State<OwnerNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const OwnerHomeScreen(),
    const ReminderScreen(),
    const FindClinicsScreen(),
    const OwnerProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Pets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_outlined),
              activeIcon: Icon(Icons.notifications_none),
              label: 'Reminders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital_outlined),
              activeIcon: Icon(Icons.local_hospital),
              label: 'Vets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
