import 'package:flutter/material.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  bool calendarMode = false;
  String statusFilter = 'All';
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New Appointment', style: TextStyle(color: Colors.white))
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                    )
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.filter_list), 
                  label: const Text('Filter')
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
                      child: Text('List')
                    ), 
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12), 
                      child: Text('Calendar')
                    )
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Confirmed', 'Pending', 'Urgent'].map<Widget>((t) => Padding(
                        padding: const EdgeInsets.only(right: 8), 
                        child: ChoiceChip(
                          label: Text(t), 
                          selected: statusFilter == t, 
                          onSelected: (_) => setState(() => statusFilter = t)
                        )
                      )).toList(),
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
    return ListView(
      children: [
        _AppointmentCard(time: '08:30', pet: 'Bella', owner: 'Mrs. Smith', type: 'Check-up', duration: '30m'),
        _AppointmentCard(time: '09:00', pet: 'Max', owner: 'Mr. Lee', type: 'Vaccination', duration: '15m'),
        _AppointmentCard(time: '10:15', pet: 'Luna', owner: 'Dr. Kim', type: 'Surgery Consult', duration: '45m'),
      ],
    );
  }

  Widget _buildCalendarView() {
    // Simple month header + grid placeholder
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () => setState(() => selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1)), icon: const Icon(Icons.chevron_left)),
            Text('${_monthName(selectedMonth.month)} ${selectedMonth.year}', style: const TextStyle(fontWeight: FontWeight.w700)),
            IconButton(onPressed: () => setState(() => selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1)), icon: const Icon(Icons.chevron_right)),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
                      decoration: BoxDecoration(color: Colors.blue[50], 
                      borderRadius: BorderRadius.circular(6)), 
                      child: const Text(
                        '2 appts', 
                        style: TextStyle(fontSize: 10, color: Colors.blue)
                      )
                    )
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
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}

class _AppointmentCard extends StatelessWidget {
  final String time;
  final String pet;
  final String owner;
  final String type;
  final String duration;
  const _AppointmentCard({required this.time, required this.pet, required this.owner, required this.type, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 68, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(time, style: const TextStyle(fontWeight: FontWeight.w700)), 
                  const SizedBox(height: 6), 
                  Text(duration, style: const TextStyle(color: Colors.grey))
                ]
              )
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text('$pet — $type', style: const TextStyle(fontWeight: FontWeight.w700)), 
                  const SizedBox(height: 4), 
                  Text(owner, style: const TextStyle(color: Colors.grey))
                ]
              )
            ),
            ElevatedButton(
              onPressed: () {}, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green), 
              child: const Text('Confirm')
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () {}, child: const Text('View')),
            const SizedBox(width: 8),
            TextButton(onPressed: () {}, child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
