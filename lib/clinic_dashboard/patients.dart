import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final clinicId = _authService.currentUserId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFFF6F8FB),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('appointments')
                .where('clinicId', isEqualTo: clinicId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data?.docs ?? [];

              // Filter for confirmed status and deduplicate by petId
              final Map<String, dynamic> uniquePets = {};
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['status'] == 'Confirmed' ||
                    data['status'] == 'accepted') {
                  final petId = data['petId'] ?? '';
                  if (petId.isNotEmpty && !uniquePets.containsKey(petId)) {
                    uniquePets[petId] = {'appointmentId': doc.id, 'data': data};
                  }
                }
              }

              final confirmedDocs = uniquePets.values.toList();
              if (confirmedDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'No patients found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clinic ID: $clinicId',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: confirmedDocs.length,
                itemBuilder: (context, i) {
                  final appointmentId = confirmedDocs[i]['appointmentId'];
                  final data = confirmedDocs[i]['data'] as Map<String, dynamic>;
                  final ownerId = data['ownerId'] ?? '';
                  final petId = data['petId'] ?? '';

                  // Use FutureBuilder to fetch both owner and pet details
                  return FutureBuilder<List<dynamic>>(
                    future: Future.wait([
                      _firestore.collection('owners').doc(ownerId).get(),
                      _firestore.collection('pets').doc(petId).get(),
                    ]),
                    builder: (context, snapshots) {
                      String ownerName = 'Unknown Owner';
                      String ownerPhone = '--';
                      String petName = data['petName'] ?? 'Unknown Pet';
                      String breed = data['breed'] ?? '--';
                      String species = data['species'] ?? '--';
                      String age = data['age']?.toString() ?? '--';
                      String height = data['height']?.toString() ?? '--';
                      String weight = data['weight']?.toString() ?? '--';

                      if (snapshots.hasData) {
                        final ownerDoc = snapshots.data![0] as DocumentSnapshot;
                        final petDoc = snapshots.data![1] as DocumentSnapshot;

                        if (ownerDoc.exists) {
                          final ownerData =
                              ownerDoc.data() as Map<String, dynamic>? ?? {};
                          // Try multiple field names for owner name from owners collection
                          ownerName =
                              ownerData['fullName'] ??
                              ownerData['name'] ??
                              ownerData['firstName'] ??
                              ownerData['lastName'] ??
                              ownerData['displayName'] ??
                              ownerData['ownerName'] ??
                              'Unknown Owner';
                          ownerPhone =
                              ownerData['phone'] ??
                              ownerData['phoneNumber'] ??
                              '--';
                        }

                        if (petDoc.exists) {
                          final petData =
                              petDoc.data() as Map<String, dynamic>? ?? {};
                          petName =
                              petData['name'] ?? petData['petName'] ?? petName;
                          breed = petData['breed'] ?? breed;
                          species =
                              petData['species'] ?? petData['type'] ?? species;
                          age = petData['age']?.toString() ?? age;
                          height = petData['height']?.toString() ?? height;
                          weight = petData['weight']?.toString() ?? weight;
                        }
                      }

                      return _PatientCard(
                        appointmentId: appointmentId,
                        patientName: petName,
                        breed: breed,
                        age: age,
                        height: height,
                        weight: weight,
                        ownerName: ownerName,
                        ownerPhone: ownerPhone,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String appointmentId;
  final String patientName;
  final String breed;
  final String age;
  final String height;
  final String weight;
  final String ownerName;
  final String ownerPhone;

  const _PatientCard({
    required this.appointmentId,
    required this.patientName,
    required this.breed,
    required this.age,
    required this.height,
    required this.weight,
    required this.ownerName,
    required this.ownerPhone,
  });

  String get displayPatientName =>
      patientName.isNotEmpty ? patientName : 'Unknown';
  String get displayBreed => breed.isNotEmpty ? breed : '--';
  String get displayAge => age.isNotEmpty ? age : '--';
  String get displayHeight => height.isNotEmpty ? height : '--';
  String get displayWeight => weight.isNotEmpty ? weight : '--';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/medical_records',
        arguments: appointmentId,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayPatientName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Owner: $ownerName',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'Breed: $displayBreed',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Age: $displayAge years',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Height: $displayHeight cm',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Weight: $displayWeight kg',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'Contact: $ownerPhone',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
