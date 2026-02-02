import 'package:flutter/material.dart';
import 'package:petcare_app/models/appointment_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

class VetDashboard extends StatefulWidget {
  const VetDashboard({Key? key}) : super(key: key);

  @override
  _VetDashboardState createState() => _VetDashboardState();
}
// ...existing code...

class _VetDashboardState extends State<VetDashboard> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Appointment> appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConfirmedAppointments();
  }

  Future<void> _fetchConfirmedAppointments() async {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // ignore: unused_local_variable
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final snapshot = await _firestore
        .collection('appointments')
        .where('clinicId', isEqualTo: uid)
        .where('status', isEqualTo: 'Confirmed')
        .get();
    final appts = snapshot.docs.map((doc) {
      final data = doc.data();
      final dateTime = data['dateTime'] is Timestamp
          ? (data['dateTime'] as Timestamp).toDate()
          : (data['dateTime'] as DateTime);
      final timeOfDay = TimeOfDay.fromDateTime(dateTime);
      return Appointment(
        id: doc.id,
        petName: data['pet'] ?? '-',
        ownerName: data['ownerName'] ?? '-',
        phone: data['phone'] ?? '-',
        type: data['type'] ?? '-',
        date: dateTime,
        time: timeOfDay,
        reason: data['notes'] ?? '-',
        status: data['status'] ?? 'Confirmed',
      );
    }).toList();
    setState(() {
      appointments = appts;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayAppointments =
        appointments
            .where(
              (a) =>
                  a.date.year == now.year &&
                  a.date.month == now.month &&
                  a.date.day == now.day,
            )
            .toList()
          ..sort((a, b) => a.time.hour.compareTo(b.time.hour));
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final thisWeekAppointments = appointments
        .where(
          (a) =>
              a.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              a.date.isBefore(endOfWeek.add(const Duration(days: 1))),
        )
        .toList();
    final totalAppointments = appointments.length;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Veterinary Dashboard',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 400
                                  ? 18
                                  : 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: MediaQuery.of(context).size.width < 400
                                  ? 11
                                  : 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification bell with badge
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_none,
                            size: MediaQuery.of(context).size.width < 400
                                ? 22
                                : 24,
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                      ? 9
                                      : 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Stats grid - Responsive layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double spacing = 12;
                    final double minCellWidth = 100;
                    final int crossAxisCount =
                        (constraints.maxWidth / (minCellWidth + spacing))
                            .floor()
                            .clamp(1, 3);
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: 0.8,
                      children: [
                        _StatCard(
                          color: Colors.blue,
                          icon: Icons.calendar_today,
                          number: todayAppointments.length.toString(),
                          label: "Today's Appointments",
                          trend: '+${todayAppointments.length} today',
                        ),
                        _StatCard(
                          color: Colors.green,
                          icon: Icons.people,
                          number: thisWeekAppointments.length.toString(),
                          label: 'This Week',
                          trend: '+${thisWeekAppointments.length} this week',
                        ),
                        _StatCard(
                          color: Colors.amber,
                          icon: Icons.description,
                          number: totalAppointments.toString(),
                          label: 'Total Confirmed',
                          trend: '${totalAppointments} confirmed',
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Appointments',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 400
                                ? 14
                                : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: todayAppointments.isEmpty
                                  ? 1
                                  : todayAppointments.length,
                              itemBuilder: (_, i) => todayAppointments.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: Text('No appointments today'),
                                      ),
                                    )
                                  : _AppointmentTileWithDelete(
                                      appointment: todayAppointments[i],
                                      onDelete: () async {
                                        try {
                                          await _firestore
                                              .collection('appointments')
                                              .doc(todayAppointments[i].id)
                                              .delete();
                                          setState(
                                            () => appointments.removeWhere(
                                              (a) =>
                                                  a.id ==
                                                  todayAppointments[i].id,
                                            ),
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Appointment deleted',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error deleting: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String number;
  final String label;
  final String trend;
  const _StatCard({
    required this.color,
    required this.icon,
    required this.number,
    required this.label,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = MediaQuery.of(context).size.width < 400 ? 22 : 26;
    final double numberFontSize = MediaQuery.of(context).size.width < 400 ? 15 : 17;
    final double labelFontSize = MediaQuery.of(context).size.width < 400 ? 8 : 10;
    final double trendFontSize = MediaQuery.of(context).size.width < 400 ? 8 : 9;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          const SizedBox(height: 6),
          Text(
            number,
            style: TextStyle(
              fontSize: numberFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: labelFontSize,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              trend,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: trendFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// legacy simple tile removed in favor of appointment model-backed tile
class _AppointmentTileWithDelete extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onDelete;
  const _AppointmentTileWithDelete({
    required this.appointment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double timeFontSize = MediaQuery.of(context).size.width < 400 ? 12 : 14;
    final double petNameFontSize = MediaQuery.of(context).size.width < 400 ? 13 : 15;
    final double statusFontSize = MediaQuery.of(context).size.width < 400 ? 10 : 12;

    Color statusColor = Colors.grey;
    if (appointment.status == 'Confirmed') statusColor = Colors.green;
    if (appointment.status == 'Pending') statusColor = Colors.orange;
    if (appointment.status == 'Urgent') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.formatTime(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: timeFontSize,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: statusFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${appointment.petName} — ${appointment.type}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: petNameFontSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.ownerName,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: petNameFontSize - 2,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            onSelected: (v) {
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Quick actions and recent activity removed (data will come from Firebase)
