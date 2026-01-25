import 'package:flutter/material.dart';
import 'package:petcare_app/profile_creen/clinic_profile.dart';

class ClinicNavigation extends StatefulWidget {
  const ClinicNavigation({super.key});

  @override
  State<ClinicNavigation> createState() => _ClinicNavigationState();
}

class _ClinicNavigationState extends State<ClinicNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ClinicHomeScreen(),
    const PatientsScreen(),
    const ClinicAppointmentsScreen(),
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
class ClinicHomeScreen extends StatelessWidget {
  const ClinicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Dashboard')),
      body: const Center(child: Text('Clinic Dashboard Screen')),
    );
  }
}

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Patients')),
      body: const Center(child: Text('Patients Screen')),
    );
  }
}

class ClinicAppointmentsScreen extends StatelessWidget {
  const ClinicAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Appointments')),
      body: const Center(child: Text('Clinic Appointments Screen')),
    );
  }
}
