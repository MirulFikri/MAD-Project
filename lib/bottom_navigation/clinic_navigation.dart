import 'package:flutter/material.dart';
import 'package:petcare_app/profile_creen/clinic_profile.dart';
import 'package:petcare_app/clinic_dashboard/vet_dashboard.dart';
import 'package:petcare_app/clinic_dashboard/appointments.dart';
import 'package:petcare_app/clinic_dashboard/patients.dart';

class ClinicNavigation extends StatefulWidget {
  const ClinicNavigation({super.key});

  @override
  State<ClinicNavigation> createState() => _ClinicNavigationState();
}

class _ClinicNavigationState extends State<ClinicNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const VetDashboard(),
    const PatientsPage(),
    const AppointmentsPage(),
    const ClinicProfile(),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              activeIcon: Icon(Icons.business),
              label: 'Profile',
            ),
          ],
        ),
      )
    );
  }
}

// Placeholder screens - create these files later
// The screens are implemented in lib/clinic_dashboard/*.dart
