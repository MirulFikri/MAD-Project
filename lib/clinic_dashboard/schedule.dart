import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool dayView = true;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white), label: const Text('New Appointment', style: TextStyle(color: Colors.white)))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            IconButton(onPressed: () => setState(() => selectedDate = selectedDate.subtract(const Duration(days: 1))), icon: const Icon(Icons.chevron_left)),
            TextButton(onPressed: () => setState(() => selectedDate = DateTime.now()), child: const Text('Today')),
            IconButton(onPressed: () => setState(() => selectedDate = selectedDate.add(const Duration(days: 1))), icon: const Icon(Icons.chevron_right)),
            const SizedBox(width: 12),
            ToggleButtons(isSelected: [dayView, !dayView], onPressed: (i) => setState(() => dayView = i == 0), children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Day')), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Week'))]),
          ]),
          const SizedBox(height: 12),
          Expanded(child: dayView ? _buildDayView() : _buildWeekView()),
          const SizedBox(height: 12),
          _SummaryStats(),
        ]),
      ),
    );
  }

  Widget _buildDayView() {
    final times = List.generate(13, (i) => 8 + i); // 8 AM to 8 PM
    return Row(children: [
      SizedBox(
        width: 80,
        child: Column(children: times.map((h) => SizedBox(height: 80, child: Align(alignment: Alignment.centerLeft, child: Text('${h.toString().padLeft(2, '0')}:00')))).toList()),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: times.map((h) => Container(height: 80, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.15), style: BorderStyle.solid), borderRadius: BorderRadius.circular(8),), child: Stack(children: [
            // example appointment block
            if (h == 9)
              Positioned(left: 8, right: 8, top: 8, bottom: 8, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Max — Vaccination', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Mr. Lee • 15m')]))),
          ]))).toList()),
        ),
      ),
    ]);
  }

  Widget _buildWeekView() {
    final days = List.generate(7, (i) => DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 - i)));
    return Column(children: [
      Row(children: days.map<Widget>((d) => Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isSameDate(d, DateTime.now()) ? Colors.blue[50] : Colors.white, borderRadius: BorderRadius.circular(6)), child: Column(children: [Text('${d.month}/${d.day}', style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), const Text('2 appts', style: TextStyle(fontSize: 12))])))).toList()),
      const SizedBox(height: 12),
      Expanded(child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 3), itemCount: 7 * 8, itemBuilder: (_, i) => Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.12)), borderRadius: BorderRadius.circular(6))))),
    ]);
  }

  bool isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SummaryStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _StatSmall(label: 'Total Appointments', value: '12'),
      _StatSmall(label: 'Total Hours', value: '6h'),
      _StatSmall(label: 'Emergencies', value: '1'),
    ]);
  }
}

class _StatSmall extends StatelessWidget {
  final String label, value;
  const _StatSmall({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))]);
  }
}
