import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:petcare_app/profile_screen/edit_owner_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authService.currentUserId != null
            ? authService.getUserData(authService.currentUserId!)
            : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data ?? {};
          final user = authService.currentUser;
          final name =
              (profile['name'] as String?) ?? user?.displayName ?? 'Pet Owner';
          final email = (profile['email'] as String?) ?? user?.email ?? '—';
          final phone = (profile['phone'] as String?) ?? '—';

          return FutureBuilder<int>(
            future: _getPetCount(authService.currentUserId ?? ''),
            builder: (context, petSnapshot) {
              final petCount = petSnapshot.data ?? 0;

              return FutureBuilder<String>(
                future: _getNextReminder(authService.currentUserId ?? ''),
                builder: (context, reminderSnapshot) {
                  final nextReminder = reminderSnapshot.data ?? '—';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProfileHeader(name: name),
                        const SizedBox(height: 24),

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

                        Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pet Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  children: [
                                    _buildSummaryCard(
                                      emoji: '🐾',
                                      title: 'Total pets',
                                      value: '$petCount',
                                    ),
                                    _buildSummaryCard(
                                      emoji: '⏰',
                                      title: 'Next reminder',
                                      value: nextReminder,
                                    ),
                                    _buildSummaryCard(
                                      emoji: '🏥',
                                      title: 'Last vet visit',
                                      value:
                                          (profile['lastVisit'] as String?) ??
                                          '—',
                                    ),
                                    FutureBuilder<String>(
                                      future: _getUpcomingAppointment(
                                        authService.currentUserId ?? '',
                                      ),
                                      builder: (context, appointmentSnapshot) {
                                        final appointment =
                                            appointmentSnapshot.data ?? '—';
                                        return _buildSummaryCard(
                                          emoji: '📅',
                                          title: 'Upcoming appointment',
                                          value: appointment,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditOwnerProfile(),
                            ),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: () =>
                              _showLogoutDialog(context, authService),
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
              );
            },
          );
        },
      ),
    );
  }
}

// Helpers and Firestore queries

Future<int> _getPetCount(String ownerId) async {
  if (ownerId.isEmpty) return 0;
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    return querySnapshot.docs.length;
  } catch (e) {
    print('Error fetching pet count: $e');
    return 0;
  }
}

Future<String> _getNextReminder(String ownerId) async {
  if (ownerId.isEmpty) return '—';
  try {
    final remindersSnapshot = await FirebaseFirestore.instance
        .collection('reminders')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('scheduledAt', descending: false)
        .limit(1)
        .get();
    if (remindersSnapshot.docs.isNotEmpty) {
      final reminderData = remindersSnapshot.docs.first.data();
      final scheduledAt = reminderData['scheduledAt'] as Timestamp?;
      if (scheduledAt != null) {
        final date = scheduledAt.toDate();
        return '${date.month}/${date.day}/${date.year}';
      }
    }
    return '—';
  } catch (e) {
    print('Error fetching next reminder: $e');
    return '—';
  }
}

Future<String> _getUpcomingAppointment(String ownerId) async {
  if (ownerId.isEmpty) return '—';
  try {
    final now = DateTime.now();
    final appointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('dateTime', descending: false)
        .get();

    for (final doc in appointmentsSnapshot.docs) {
      final data = doc.data();
      final appointmentDate = data['dateTime'];

      DateTime? dateTime;
      if (appointmentDate is Timestamp) {
        dateTime = appointmentDate.toDate();
      } else if (appointmentDate is String) {
        try {
          dateTime = DateTime.parse(appointmentDate);
        } catch (_) {}
      }

      if (dateTime != null && dateTime.isAfter(now)) {
        return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
      }
    }

    return '—';
  } catch (e) {
    print('Error fetching upcoming appointment: $e');
    return '—';
  }
}

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

Widget _buildInfoCard({required String title, required List<Widget> children}) {
  return Card(
    color: Colors.white,
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
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

Widget _buildSummaryCard({
  required String emoji,
  required String title,
  required String value,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.blue.shade100),
    ),
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
            }
          },
          child: const Text('Log Out', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
}
