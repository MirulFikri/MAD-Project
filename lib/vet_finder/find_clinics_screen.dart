import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class FindClinicsScreen extends StatefulWidget {
  const FindClinicsScreen({super.key});

  @override
  State<FindClinicsScreen> createState() => _FindClinicsScreenState();
}

class _FindClinicsScreenState extends State<FindClinicsScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _allClinics = [];
  List<Map<String, dynamic>> _filteredClinics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinics();
    _searchCtrl.addListener(_filterClinics);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    try {
      final clinics = await _authService.getAllClinics();
      setState(() {
        _allClinics = clinics;
        _filteredClinics = clinics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load clinics: $e')));
      }
    }
  }

  void _filterClinics() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredClinics = _allClinics.where((clinic) {
        final clinicName = ((clinic['clinicName'] as String?) ?? '')
            .toLowerCase();
        final address = ((clinic['address'] as String?) ?? '').toLowerCase();
        return clinicName.contains(query) || address.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Find Vet Clinics'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFEFF7FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search clinics by name or location...',
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
                if (_filteredClinics.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        _searchCtrl.text.isEmpty
                            ? 'No clinics available'
                            : 'No clinics found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ..._filteredClinics.map((clinic) {
                    final services =
                        (clinic['services'] as List<dynamic>?) ?? [];
                    return ClinicCard(
                      uid: clinic['uid'] ?? '',
                      name: clinic['clinicName'] ?? 'Unknown Clinic',
                      distance: 'N/A',
                      location: clinic['address'] ?? 'No address',
                      contact: clinic['phone'] ?? 'N/A',
                      hours: clinic['hours'] ?? 'Hours not specified',
                      services: services.cast<String>(),
                    );
                  }).toList(),
              ],
            ),
    );
  }
}

// ---------------- CLINIC CARD ----------------

class ClinicCard extends StatelessWidget {
  final String uid;
  final String name;
  final String distance;
  final String location;
  final String contact;
  final String hours;
  final List<String> services;

  const ClinicCard({
    super.key,
    required this.uid,
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
        color: Colors.white,
        elevation: 2,
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
              if (services.isNotEmpty)
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
