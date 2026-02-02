import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';
import 'package:petcare_app/appointment/appointment_details.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool calendarMode = false;
  String statusFilter = 'All';
  DateTime selectedMonth = DateTime.now();
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      setState(() {
        appointments = [];
        _isLoading = false;
      });
      return;
    }
    final query = _firestore
        .collection('appointments')
        .where('clinicId', isEqualTo: uid);
    final snapshot = await query.get();
    setState(() {
      appointments = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'New Appointment',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search appointments',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Toggle and tabs
            Row(
              children: [
                ToggleButtons(
                  isSelected: [!calendarMode, calendarMode],
                  onPressed: (i) => setState(() => calendarMode = i == 1),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('List'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Calendar'),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Confirmed', 'Pending', 'Urgent']
                          .map<Widget>(
                            (t) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(t),
                                selected: statusFilter == t,
                                onSelected: (_) =>
                                    setState(() => statusFilter = t),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: calendarMode ? _buildCalendarView() : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final filtered = statusFilter == 'All'
        ? appointments
        : appointments.where((a) => a['status'] == statusFilter).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('No appointments found.'));
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final a = filtered[i];
        final ownerId = a['ownerId'] ?? '';

        DateTime? dateTime;
        if (a['dateTime'] != null) {
          dateTime = a['dateTime'] is Timestamp
              ? (a['dateTime'] as Timestamp).toDate()
              : (a['dateTime'] as DateTime);
        }
        final dateStr = dateTime != null
            ? '${dateTime.month}/${dateTime.day}/${dateTime.year}'
            : (a['date'] ?? '');
        final timeStr = dateTime != null
            ? TimeOfDay.fromDateTime(dateTime).format(context)
            : (a['time'] ?? '');

        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('owners').doc(ownerId).get(),
          builder: (context, ownerSnapshot) {
            String ownerName = 'Unknown Owner';
            if (ownerSnapshot.hasData && ownerSnapshot.data!.exists) {
              final ownerData =
                  ownerSnapshot.data!.data() as Map<String, dynamic>;
              ownerName =
                  ownerData['fullName'] ??
                  ownerData['name'] ??
                  ownerData['firstName'] ??
                  ownerData['lastName'] ??
                  ownerData['displayName'] ??
                  ownerData['ownerName'] ??
                  'Unknown Owner';
            }

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsScreen(
                    appointmentId: a['id'],
                    appointmentData: a,
                  ),
                ),
              ),
              child: _AppointmentCard(
                id: a['id'],
                date: dateStr,
                time: timeStr,
                pet: a['pet'] ?? '',
                ownerName: ownerName,
                type: a['type'] ?? '',
                status: a['status'] ?? 'Pending',
                onStatusChange: (status) async {
                  await _firestore.collection('appointments').doc(a['id']).update(
                    {'status': status},
                  );
                  await _loadAppointments();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarView() {
    // Simple month header + grid placeholder
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(
                () => selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month - 1,
                ),
              ),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${_monthName(selectedMonth.month)} ${selectedMonth.year}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: () => setState(
                () => selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month + 1,
                ),
              ),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: 35,
            itemBuilder: (_, i) => Card(
              margin: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}'),
                    const Spacer(),
                    if (i % 7 == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '2 appts',
                          style: TextStyle(fontSize: 10, color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class _AppointmentCard extends StatelessWidget {
  final String id;
  final String date;
  final String time;
  final String pet;
  final String ownerName;
  final String type;
  final String status;
  final void Function(String status) onStatusChange;
  const _AppointmentCard({
    required this.id,
    required this.date,
    required this.time,
    required this.pet,
    required this.ownerName,
    required this.type,
    required this.status,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pet — $type',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(ownerName, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (status == 'Pending') ...[
              ElevatedButton(
                onPressed: () => onStatusChange('Confirmed'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Accept'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => onStatusChange('Declined'),
                child: const Text('Decline'),
              ),
            ] else ...[
              Text(
                status,
                style: TextStyle(
                  color: status == 'Confirmed' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
