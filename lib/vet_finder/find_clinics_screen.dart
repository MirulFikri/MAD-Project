import 'package:flutter/material.dart';

class FindClinicsScreen extends StatelessWidget {
  const FindClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Find Vet Clinics'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFEFF7FF),

      // ✅ SCROLLABLE PAGE
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search clinics...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const ClinicCard(
            name: 'Paws & Claws Clinic',
            distance: '2.6 km',
            location: '123 Main Street, Downtown',
            contact: '012-345 6789',
            hours: 'Mon–Fri: 8AM – 6PM',
            services: ['Surgery', 'Emergency', 'Dental'],
          ),
          const ClinicCard(
            name: 'Happy Tails Hospital',
            distance: '3.6 km',
            location: '456 Oak Avenue, Midtown',
            contact: '013-987 6543',
            hours: 'Mon–Sun: 9AM – 9PM',
            services: ['Surgery', 'Grooming'],
          ),
          const ClinicCard(
            name: 'Pet Wellness Center',
            distance: '5.2 km',
            location: '789 Pine Road, Uptown',
            contact: '011-222 3333',
            hours: 'Mon–Fri: 9AM – 5PM',
            services: ['Check-up', 'Dental Care'],
          ),
        ],
      ),
    );
  }
}

// ---------------- CLINIC CARD ----------------

class ClinicCard extends StatelessWidget {
  final String name;
  final String distance;
  final String location;
  final String contact;
  final String hours;
  final List<String> services;

  const ClinicCard({
    super.key,
    required this.name,
    required this.distance,
    required this.location,
    required this.contact,
    required this.hours,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Card(
        color: const Color.fromARGB(255, 202, 204, 207),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.local_hospital, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(distance, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      contact,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                  Text(
                    hours,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: services
                    .map(
                      (service) => Chip(
                        label: Text(service),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
