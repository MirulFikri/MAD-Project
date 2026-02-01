import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ClinicProfile extends StatelessWidget {
  const ClinicProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FF), // Light blue background
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authService.currentUserId != null 
            ? authService.getUserData(authService.currentUserId!) 
            : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data ?? {};
          final user = authService.currentUser;
          final clinicName = (profile['clinicName'] as String?) ?? user?.displayName ?? 'Vet Clinic';
          final subtitle = 'Clinic Account';
          final email = (profile['email'] as String?) ?? user?.email ?? '—';
          final phone = (profile['phone'] as String?) ?? '—';
          final location = (profile['address'] as String?) ?? '—';
          final hours = (profile['hours'] as String?) ?? '—';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- HEADER: Clinic Image & Name ---
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue[100],
                          // You can change this Icon to an Image later using AssetImage
                          child: const Icon(Icons.local_hospital, size: 50, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        clinicName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- DETAILS SECTION ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Clinic Information",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileRow(Icons.email_outlined, "Email", email),
                      const Divider(height: 30),
                      _buildProfileRow(Icons.phone_outlined, "Phone", phone),
                      const Divider(height: 30),
                      _buildProfileRow(Icons.location_on_outlined, "Location", location),
                      const Divider(height: 30),
                      _buildProfileRow(Icons.access_time, "Hours", hours),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- LOGOUT BUTTON ---
                OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context, authService);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await authService.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Helper widget to create the rows (Email, Phone, etc.)
  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}