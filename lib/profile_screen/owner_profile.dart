import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OwnerProfile extends StatelessWidget {
  const OwnerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FF),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        centerTitle: true,
      ),

      // ✅ SCROLLABLE
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
          final name = (profile['name'] as String?) ?? user?.displayName ?? 'Pet Owner';
          final email = (profile['email'] as String?) ?? user?.email ?? '—';
          final phone = (profile['phone'] as String?) ?? '—';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ===== PROFILE HEADER =====
                _buildProfileHeader(name: name),

                const SizedBox(height: 24),

                // ===== ACCOUNT INFO =====
                _buildInfoCard(
                  title: 'Account Information',
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Name',
                      value: name,
                    ),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: phone,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ===== PET INFO =====
                _buildInfoCard(
                  title: 'My Pets',
                  children: const [
                    _InfoRow(icon: Icons.pets, label: 'Pet Name', value: 'Buddy'),
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: 'Type',
                      value: 'Dog',
                    ),
                    _InfoRow(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: '3 years',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ===== ACTION BUTTONS =====
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),

                const SizedBox(height: 12),

                // Logout Button
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

  // ================= WIDGETS =================

  Widget _buildProfileHeader({required String name}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, size: 50, color: Colors.blue),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Pet Owner', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
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
}

// ================= INFO ROW =================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
