import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'edit_clinic_profile.dart';

class ClinicProfile extends StatefulWidget {
  const ClinicProfile({super.key});

  @override
  State<ClinicProfile> createState() => _ClinicProfileState();
}

class _ClinicProfileState extends State<ClinicProfile> {
  final AuthService _authService = AuthService();
  
  /// Key used to force refresh the FutureBuilder when profile is updated
  /// Incrementing this key causes the FutureBuilder to rebuild with fresh data
  int _refreshKey = 0;

  void _refreshProfile() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FF),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      // FutureBuilder fetches clinic data from Firestore asynchronously
      // and updates the UI as data loads
      body: FutureBuilder<Map<String, dynamic>?>(
        key: ValueKey(_refreshKey),
        future: _authService.currentUserId != null
            ? _authService.getUserData(_authService.currentUserId!)
            : Future.value(null),
        builder: (context, snapshot) {
          // Show loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract clinic profile data from snapshot, using defaults if not found
          final profile = snapshot.data ?? {};
          final user = _authService.currentUser;
          final clinicName =
              (profile['clinicName'] as String?) ??
              user?.displayName ??
              'Vet Clinic';
          final subtitle = 'Clinic Account';
          final email = (profile['email'] as String?) ?? user?.email ?? '—';
          final phone = (profile['phone'] as String?) ?? '—';
          final location = (profile['address'] as String?) ?? '—';
          final hours = (profile['hours'] as String?) ?? '—';
          final services = (profile['services'] as List<dynamic>?) ?? [];
          final servicesList = services.cast<String>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Display the clinic's avatar/logo and name
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      // Clinic avatar with blue hospital icon
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue[100],
                          child: const Icon(
                            Icons.local_hospital,
                            size: 50,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        clinicName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Account type label
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Card containing clinic contact information
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Display each clinic detail (email, phone, location, hours)
                      _buildProfileRow(Icons.email_outlined, "Email", email),
                      const Divider(height: 30),
                      _buildProfileRow(Icons.phone_outlined, "Phone", phone),
                      const Divider(height: 30),
                      _buildProfileRow(
                        Icons.location_on_outlined,
                        "Location",
                        location,
                      ),
                      const Divider(height: 30),
                      _buildProfileRow(Icons.access_time, "Hours", hours),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Display list of services offered by the clinic (if any exist)
                if (servicesList.isNotEmpty)
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
                          "Services Offered",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display services as tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: servicesList.map((service) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.blue[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                service,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Edit button
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditClinicProfile(),
                      ),
                    );
                    // Refresh profile after returning from edit screen
                    _refreshProfile();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),

                const SizedBox(height: 12),

                // Logout button
                OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context, _authService);
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
                // Sign out the user from Firebase
                await authService.signOut();
                // Navigate to login screen and remove all previous screens from stack
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

  /// Displays an icon, label, and value in a row format with proper styling
  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                maxLines: null,
                softWrap: true,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
