import 'package:flutter/material.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        actions: [
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file, color: Colors.white), label: const Text('Export', style: TextStyle(color: Colors.white))),
          const SizedBox(width: 8),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Add Record', style: TextStyle(color: Colors.white))),
        ],
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'History'), Tab(text: 'Vaccinations'), Tab(text: 'Medications'), Tab(text: 'Lab Results')]),
      ),
      body: TabBarView(controller: _tabController, children: [
        _HistoryTab(),
        _VaccinationsTab(),
        _MedicationsTab(),
        _LabResultsTab(),
      ]),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        _TimelineCard(title: 'Routine check', date: '2026-01-20', vet: 'Dr. Anderson', details: 'All good'),
        _TimelineCard(title: 'Stitch removal', date: '2025-12-01', vet: 'Dr. Lee', details: 'Recovery normal'),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String title;
  final String date;
  final String vet;
  final String details;
  const _TimelineCard({required this.title, required this.date, required this.vet, required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.12), child: const Icon(Icons.health_and_safety, color: Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text('$date • $vet'), const SizedBox(height: 6), Text(details, style: const TextStyle(color: Colors.grey))])),
        ],
      ),
    );
  }
}

class _VaccinationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: const [
        _VaccineCard(name: 'Rabies', last: '2025-11-20', nextDue: '2026-11-20'),
        _VaccineCard(name: 'Distemper', last: '2025-11-20', nextDue: '2026-11-20'),
      ],
    );
  }
}

class _VaccineCard extends StatelessWidget {
  final String name;
  final String last;
  final String nextDue;
  const _VaccineCard({required this.name, required this.last, required this.nextDue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      child: Row(children: [
        const Icon(Icons.vaccines, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700)), Text('Last: $last • Next: $nextDue', style: const TextStyle(color: Colors.grey, fontSize: 12))])),
      ]),
    );
  }
}

class _MedicationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(12), children: const [
      _MedicationCard(name: 'Amoxicillin', type: 'Antibiotic', dosage: '250mg', freq: '2x/day', start: '2026-01-10', end: '2026-01-20'),
    ]);
  }
}

class _MedicationCard extends StatelessWidget {
  final String name, type, dosage, freq, start, end;
  const _MedicationCard({required this.name, required this.type, required this.dosage, required this.freq, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text('$type • $dosage • $freq'), const SizedBox(height: 6), Text('Period: $start - $end', style: const TextStyle(color: Colors.grey))]),
    );
  }
}

class _LabResultsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(12), children: const [
      _LabCard(test: 'CBC', date: '2026-01-19', status: 'Normal'),
    ]);
  }
}

class _LabCard extends StatelessWidget {
  final String test, date, status;
  const _LabCard({required this.test, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    if (status.toLowerCase() != 'normal') color = Colors.orange;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
      child: Row(children: [
        const Icon(Icons.analytics, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(child: Text('$test • $date', style: const TextStyle(fontWeight: FontWeight.w700))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: color))),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: () {}, child: const Text('Download'))
      ]),
    );
  }
}
