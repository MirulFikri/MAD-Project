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
                .where('status', isEqualTo: 'Confirmed')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No confirmed patients yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
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
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  return _PatientCard(
                    patientName: data['petName'] ?? '',
                    breed: data['breed'] ?? '',
                    age: data['age']?.toString() ?? '',
                    height: data['height']?.toString() ?? '',
                    weight: data['weight']?.toString() ?? '',
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
  final String patientName;
  final String breed;
  final String age;
  final String height;
  final String weight;

  _PatientCard({
    required this.patientName,
    required this.breed,
    required this.age,
    required this.height,
    required this.weight,
  });

  String get displayPatientName => patientName.isNotEmpty ? patientName : 'Unknown';
  String get displayBreed => breed.isNotEmpty ? breed : '--';
  String get displayAge => age.isNotEmpty ? age : '--';
  String get displayHeight => height.isNotEmpty ? height : '--';
  String get displayWeight => weight.isNotEmpty ? weight : '--';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/medical_records'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF6366F1)]),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayPatientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Breed: $displayBreed', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text('Age: $displayAge', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('Height: $displayHeight cm', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('Weight: $displayWeight kg', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
