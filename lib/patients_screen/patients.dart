import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';
import 'package:petcare_app/patients_screen/patinet_details.dart';

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
                .collection('pets')
                .where('treatingClinics', arrayContains: clinicId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
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
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final petData = docs[i].data() as Map<String, dynamic>;
                  final petId = docs[i].id;
                  final ownerId = petData['ownerId'] ?? '';
                  final petName = petData['name'] ?? 'Unknown Pet';
                  final breed = petData['breed'] ?? '--';
                  final age = petData['age']?.toString() ?? '--';
                  final height = petData['height']?.toString() ?? '--';
                  final weight = petData['weight']?.toString() ?? '--';

                  // Fetch owner details
                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('owners').doc(ownerId).get(),
                    builder: (context, ownerSnapshot) {
                      String ownerName = 'Unknown Owner';
                      String ownerPhone = '--';

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
                        ownerPhone =
                            ownerData['phone'] ??
                            ownerData['phoneNumber'] ??
                            '--';
                      }

                      return _PatientCard(
                        appointmentId: petId,
                        patientName: petName,
                        breed: breed,
                        age: age,
                        height: height,
                        weight: weight,
                        ownerName: ownerName,
                        ownerPhone: ownerPhone,
                        petId: petId,
                        ownerId: ownerId,
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
  final String petId;
  final String ownerId;

  const _PatientCard({
    required this.appointmentId,
    required this.patientName,
    required this.breed,
    required this.age,
    required this.height,
    required this.weight,
    required this.ownerName,
    required this.ownerPhone,
    required this.petId,
    required this.ownerId,
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientDetailsScreen(
            appointmentId: appointmentId,
            petId: petId,
            ownerId: ownerId,
            patientName: patientName,
            ownerName: ownerName,
            ownerPhone: ownerPhone,
            breed: breed,
            age: age,
            height: height,
            weight: weight,
          ),
        ),
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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayPatientName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Owner: $ownerName',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Breed: $displayBreed',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                'Age: $displayAge years',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                'Height: $displayHeight cm',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 3),
              Text(
                'Weight: $displayWeight kg',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Contact: $ownerPhone',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
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
