import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

class PetProfile extends StatefulWidget {
  const PetProfile({super.key});

  @override
  State<PetProfile> createState() => _PetProfileState();
}

class _PetProfileState extends State<PetProfile> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedPet;
  List<String> _pets = [];
  Map<String, dynamic>? _selectedPetData;
  List<Map<String, dynamic>> _healthRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: uid)
          .get();

      final petNames = snapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        _pets = petNames;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading pets: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPetData(String petId) async {
    try {
      final petDoc = await _firestore.collection('pets').doc(petId).get();

      final recordsSnapshot = await _firestore
          .collection('medicalRecords')
          .where('petId', isEqualTo: petId)
          .get();

      final records = recordsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _selectedPetData = petDoc.data() as Map<String, dynamic>?;
        _healthRecords = records;
      });
    } catch (e) {
      print('Error loading pet data: $e');
    }
  }

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _pets.isEmpty
            ? Center(
                child: Text(
                  'No pets found. Add a pet to get started!',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown for pets
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPet,
                            hint: const Text('Select a pet'),
                            isExpanded: true,
                            items: _pets
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() => _selectedPet = v);
                              if (v != null) {
                                _loadPetData(v);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedPetData != null) ...[
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
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text('🐕', style: TextStyle(fontSize: 40)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (_selectedPetData?['name'] as String?) ??
                                          'Pet name',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (_selectedPetData?['breed'] as String?) ??
                                          'Breed',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _InfoTile(
                                    label: 'Age',
                                    value:
                                        (_selectedPetData?['age'] as String?) ??
                                        '-',
                                  ),
                                  _InfoTile(
                                    label: 'Weight',
                                    value:
                                        (_selectedPetData?['weight']
                                            as String?) ??
                                        '-',
                                  ),
                                  _InfoTile(
                                    label: 'Height',
                                    value:
                                        (_selectedPetData?['height']
                                            as String?) ??
                                        '-',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _InfoTile(
                                    label: 'Gender',
                                    value:
                                        (_selectedPetData?['gender']
                                            as String?) ??
                                        '-',
                                  ),
                                  _InfoTile(
                                    label: 'Birthday',
                                    value:
                                        (_selectedPetData?['birthday']
                                            as String?) ??
                                        '-',
                                  ),
                                  const SizedBox(width: 80),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Health Records header
                        const Text(
                          'Health Records',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Records list
                        if (_healthRecords.isEmpty)
                          Center(
                            child: Text(
                              'No health records yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _healthRecords.map((record) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RecordCard(
                                  type: record['type'] as String? ?? 'Record',
                                  date: record['date'] as String? ?? '-',
                                  nextDue: record['nextDue'] as String? ?? '-',
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 24),
                        const SizedBox(height: 40),
                      ] else
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text(
                              'Select a pet to view details',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
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
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final String type;
  final String date;
  final String nextDue;
  const _RecordCard({
    required this.type,
    required this.date,
    required this.nextDue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $date',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Next: $nextDue',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
