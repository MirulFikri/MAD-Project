import 'package:flutter/material.dart';

class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Add Patient', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search patients', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list), label: const Text('Filter')),
              ],
            ),
            const SizedBox(height: 12),
            // Filter tabs
            Row(children: [
              ChoiceChip(label: const Text('All Pets'), selected: true, onSelected: (_) {}),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('Dogs'), selected: false, onSelected: (_) {}),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('Cats'), selected: false, onSelected: (_) {}),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text('Other'), selected: false, onSelected: (_) {}),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.72, mainAxisSpacing: 12, crossAxisSpacing: 12),
                itemCount: 9,
                itemBuilder: (_, i) => _PatientCard(index: i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final int index;
  const _PatientCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/medical_records'),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // gradient header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]), borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [Text('🐕', style: TextStyle(fontSize: 28)), SizedBox(width: 8), Expanded(child: Text('Bella', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),]),
                  const SizedBox(height: 6),
                  const Text('Golden Retriever', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(8)), child: const Text('Healthy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                    const Spacer(),
                    const Text('3y', style: TextStyle(color: Colors.white70)),
                  ])
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.person, size: 14, color: Colors.grey), const SizedBox(width: 6), const Expanded(child: Text('Owner info', style: TextStyle(fontSize: 12, color: Colors.grey)))]),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: () {}, child: const Text('View Medical Records'))
              ]),
            )
          ],
        ),
      ),
    );
  }
}
