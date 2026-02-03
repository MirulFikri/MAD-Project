import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

/// This screen displays the profile of a pet, including basic info and medical records.
/// Users can select a pet from a dropdown to view its details.
class PetProfile extends StatefulWidget {
  const PetProfile({super.key});

  @override
  State<PetProfile> createState() => _PetProfileState();
}

class _PetProfileState extends State<PetProfile> {

  // Handles authentication and gives access to the current user
  final AuthService _authService = AuthService();

  // Firestore instance used to fetch pet and medical record data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stores the currently selected pet ID
  String? _selectedPet;
  List<String> _pets = [];

  // Stores detailed data of the selected pet
  Map<String, dynamic>? _selectedPetData;
  List<Map<String, dynamic>> _healthRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load pets when the screen starts
    _loadPets();
  }

  // Loads all pets that belong to the currently logged-in owner
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


      // Use document ID as pet identifier
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

  // Loads detailed pet data and its medical records
  Future<void> _loadPetData(String petId) async {
    try {

      // Fetch pet details
      final petDoc = await _firestore.collection('pets').doc(petId).get();


      // Fetch medical records for the selected pet
      final recordsSnapshot = await _firestore
          .collection('medicalRecords')
          .where('petId', isEqualTo: petId)
          .get();

      final records = recordsSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      // Sort medical records by date (Latest first)
      records.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      setState(() {
        _selectedPetData = petDoc.data();
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

      // Main body of the page
      body: SafeArea(
        child: _isLoading
            // Show loading indicator while fetching data
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
                      // Dropdown to select a pet owner by the user
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
                              color: Colors.black.withValues(),
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

                      // Show pet details only after a pet i selected
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Medical Records',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${_healthRecords.length} records',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Records list
                        if (_healthRecords.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.medical_services_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No medical records yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _healthRecords.map((record) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MedicalRecordCard(record: record),
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
  final Map<String, dynamic> record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final title = record['title'] as String? ?? 'Medical Record';
    final description = record['description'] as String? ?? '';
    final date = record['date'] as String? ?? 'N/A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Alias for backward compatibility
class _MedicalRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  const _MedicalRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return _RecordCard(record: record);
  }
}
