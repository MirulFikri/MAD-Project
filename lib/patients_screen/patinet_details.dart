import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String appointmentId;
  final String petId;
  final String ownerId;
  final String patientName;
  final String ownerName;
  final String ownerPhone;
  final String breed;
  final String age;
  final String height;
  final String weight;

  const PatientDetailsScreen({
    super.key,
    required this.appointmentId,
    required this.petId,
    required this.ownerId,
    required this.patientName,
    required this.ownerName,
    required this.ownerPhone,
    required this.breed,
    required this.age,
    required this.height,
    required this.weight,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _medicalRecords = [];
  bool _isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedicalRecords();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalRecords() async {
    try {
      final snapshot = await _firestore
          .collection('medicalRecords')
          .where('appointmentId', isEqualTo: widget.appointmentId)
          .get();

      setState(() {
        _medicalRecords = snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();

        // Sort by createdAt in memory (handles missing createdAt fields)
        _medicalRecords.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime); // Descending order (newest first)
        });

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medical records: $e')),
        );
      }
    }
  }

  Future<void> _saveMedicalRecord() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await _firestore.collection('medicalRecords').add({
        'appointmentId': widget.appointmentId,
        'petId': widget.petId,
        'ownerId': widget.ownerId,
        'clinicId': _authService.currentUserId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _dateController.text.isNotEmpty
            ? _dateController.text
            : DateTime.now().toString().split(' ')[0],
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record added successfully')),
        );
        _loadMedicalRecords();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving record: $e')));
      }
    }
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medical Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Record Title',
                  hintText: 'e.g., Vaccination, Surgery, Check-up',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter medical record details...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (optional)',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateController.text = date.toString().split(' ')[0];
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveMedicalRecord,
            child: const Text('Add Record'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecord(String recordId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('medicalRecords').doc(recordId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record deleted successfully')),
          );
          _loadMedicalRecords();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting record: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordDialog,
        tooltip: 'Add Medical Record',
        child: const Icon(Icons.add),
      ),
      body: Container(
        color: const Color(0xFFF6F8FB),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Pet Name', widget.patientName),
                      _buildInfoRow('Breed', widget.breed),
                      _buildInfoRow('Age', '${widget.age} years'),
                      _buildInfoRow('Height', '${widget.height} cm'),
                      _buildInfoRow('Weight', '${widget.weight} kg'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Owner Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Owner Information',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Owner Name', widget.ownerName),
                      _buildInfoRow('Contact', widget.ownerPhone),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Medical Records Section
                Text(
                  'Medical Records',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _medicalRecords.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No medical records found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: _medicalRecords.map((record) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        record['title'] ?? 'Medical Record',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _deleteRecord(record['id']),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  record['description'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${record['date'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
