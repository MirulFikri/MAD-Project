import 'package:flutter/material.dart';

class PetProfile extends StatefulWidget {
  const PetProfile({super.key});

  @override
  State<PetProfile> createState() => _PetProfileState();
}

class _PetProfileState extends State<PetProfile> {
  String? _selectedPet;
  final List<String> _pets = []; // TODO: populate from Firebase later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown for pets
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPet,
                      hint: const Text('Select a pet'),
                      isExpanded: true,
                      items: _pets.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => _selectedPet = v),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Gradient card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🐕', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Pet name', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Breed', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Basic info grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _InfoTile(label: 'Age', value: '-'),
                          _InfoTile(label: 'Weight', value: '-'),
                          _InfoTile(label: 'Height', value: '-'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _InfoTile(label: 'Gender', value: '-'),
                          _InfoTile(label: 'Birthday', value: '-'),
                          SizedBox(width: 80),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Health Records header
                const Text('Health Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // Records list (placeholder entries)
                Column(
                  children: const [
                    _RecordCard(type: 'Vaccination', date: '-', nextDue: '-'),
                    SizedBox(height: 12),
                    _RecordCard(type: 'Check-up', date: '-', nextDue: '-'),
                  ],
                ),

                const SizedBox(height: 24),

                // End spacer
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final String type;
  final String date;
  final String nextDue;
  const _RecordCard({required this.type, required this.date, required this.nextDue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(type, style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: $date', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Next: $nextDue', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
