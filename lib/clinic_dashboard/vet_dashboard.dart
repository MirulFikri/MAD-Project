import 'package:flutter/material.dart';
import 'package:petcare_app/clinic_dashboard/create_appointment.dart';
import 'package:petcare_app/models/appointment.dart';

class VetDashboard extends StatefulWidget {
  const VetDashboard({super.key});

  @override
  State<VetDashboard> createState() => _VetDashboardState();
}

class _VetDashboardState extends State<VetDashboard> {
  late List<Appointment> appointments = [];

  @override
  Widget build(BuildContext context) {
    final todayAppointments = appointments.where((a) => a.isToday()).toList()..sort((a, b) => a.time.hour.compareTo(b.time.hour));
    final totalAppointments = appointments.length;
    final urgentCount = appointments.where((a) => a.status == 'Urgent').length;
    final confirmedCount = appointments.where((a) => a.status == 'Confirmed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      children: const [
                        Text('Veterinary Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('Welcome back, Dr. Anderson', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  // Notification bell with badge
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: const Center(
                            child: Text('3', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stats grid - TODO: Replace with Firebase data
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      color: Colors.blue,
                      icon: Icons.calendar_today,
                      number: todayAppointments.length.toString(),
                      label: "Today's Appointments",
                      trend: '+${confirmedCount > 0 ? confirmedCount : 0} confirmed',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      color: Colors.green,
                      icon: Icons.people,
                      number: totalAppointments.toString(),
                      label: 'Total Appointments',
                      trend: '+${confirmedCount} this week',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      color: Colors.amber,
                      icon: Icons.description,
                      number: urgentCount.toString(),
                      label: 'Urgent Cases',
                      trend: '${urgentCount} pending attention',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Main content - 2 column layout
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Today\'s Appointments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateAppointmentPage(onAppointmentCreated: _addAppointment))).then((_) => setState(() {})),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('New'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: todayAppointments.isEmpty ? 1 : todayAppointments.length,
                              itemBuilder: (_, i) => todayAppointments.isEmpty
                                  ? const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No appointments today')))
                                  : _AppointmentTileWithDelete(
                                      appointment: todayAppointments[i],
                                      onDelete: () => setState(() => appointments.removeWhere((a) => a.id == todayAppointments[i].id)),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right column - Alerts
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Emergency: Patient in critical condition', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
                                SizedBox(height: 6),
                                Text('Room 3 — immediate attention required', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('2 pending lab reports', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.orange)),
                                SizedBox(height: 6),
                                Text('Review when available', style: TextStyle(color: Colors.orange)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addAppointment(Appointment appointment) {
    setState(() => appointments.add(appointment));
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String number;
  final String label;
  final String trend;
  const _StatCard({required this.color, required this.icon, required this.number, required this.label, required this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
          ),
          Text(trend, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

// legacy simple tile removed in favor of appointment model-backed tile
class _AppointmentTileWithDelete extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onDelete;
  const _AppointmentTileWithDelete({required this.appointment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (appointment.status == 'Confirmed') statusColor = Colors.green;
    if (appointment.status == 'Pending') statusColor = Colors.orange;
    if (appointment.status == 'Urgent') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
      child: Row(
        children: [
          Container(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.formatTime(), style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(appointment.status, style: TextStyle(color: statusColor, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${appointment.petName} — ${appointment.type}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(appointment.ownerName, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          PopupMenuButton(
            onSelected: (v) {
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}

// Quick actions and recent activity removed (data will come from Firebase)
