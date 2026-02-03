import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;
  final Map<String, dynamic>? appointmentData;

  const AppointmentDetailsScreen({super.key, required this.appointmentId, this.appointmentData});

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _appointment;
  String _ownerName = 'Unknown Owner';
  String _ownerPhone = '—';
  String _clinicName = 'Unknown Clinic';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    try {
      // Use pre-loaded data if available, otherwise fetch from Firestore
      Map<String, dynamic>? data = widget.appointmentData;
      if (data == null || data.isEmpty) {
        final doc = await _firestore
            .collection('appointments')
            .doc(widget.appointmentId)
            .get();
        if (doc.exists) {
          // Add document ID to the data for reference
          data = {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        }
      }

      if (data != null) {
        _appointment = data;

        final ownerId = data['ownerId'] ?? '';
        final clinicId = data['clinicId'] ?? '';

        // --- LOAD OWNER INFO ---
        if (data['ownerName'] != null && data['ownerName'] != '') {
          _ownerName = data['ownerName'];
        } else if (ownerId.isNotEmpty) {
          // Query owners collection by owner ID
          final ownerDoc = await _firestore
              .collection('owners')
              .doc(ownerId)
              .get();
          if (ownerDoc.exists) {
            final ownerData = ownerDoc.data() as Map<String, dynamic>;
            _ownerName =
                ownerData['fullName'] ??
                ownerData['name'] ??
                ownerData['firstName'] ??
                ownerData['lastName'] ??
                ownerData['displayName'] ??
                ownerData['ownerName'] ??
                'Unknown Owner';
            _ownerPhone =
                ownerData['phone'] ??
                ownerData['phoneNumber'] ??
                ownerData['contactNumber'] ??
                data['phone'] ??
                '—';
          }
        }

        // Fallback to appointment data for phone if owner lookup didn't work
        if (_ownerPhone == '—' && data['phone'] != null) {
          _ownerPhone = data['phone'];
        }

        // --- LOAD CLINIC INFO ---
        if (data['clinicName'] != null && data['clinicName'] != '') {
          _clinicName = data['clinicName'];
        } else if (clinicId.isNotEmpty) {
          final clinicDoc = await _firestore
              .collection('clinics')
              .doc(clinicId)
              .get();
          if (clinicDoc.exists) {
            final clinicData = clinicDoc.data() as Map<String, dynamic>;
            _clinicName =
                clinicData['clinicName'] ??
                clinicData['name'] ??
                clinicData['displayName'] ??
                'Unknown Clinic';
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(Map<String, dynamic> a) {
    if (a['dateTime'] != null) {
      final dt = a['dateTime'] is Timestamp
          ? (a['dateTime'] as Timestamp).toDate()
          : (a['dateTime'] as DateTime);
      return '${dt.month}/${dt.day}/${dt.year}';
    }
    return a['date'] ?? '—';
  }

  String _formatTime(Map<String, dynamic> a) {
    if (a['dateTime'] != null) {
      final dt = a['dateTime'] is Timestamp
          ? (a['dateTime'] as Timestamp).toDate()
          : (a['dateTime'] as DateTime);
      return TimeOfDay.fromDateTime(dt).format(context);
    }
    return a['time'] ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        color: const Color(0xFFF6F8FB),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _appointment == null
            ? const Center(child: Text('Appointment not found'))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- APPOINTMENT SECTION ---
                      _SectionCard(
                        title: 'Appointment',
                        children: [
                          _infoRow('Pet', _appointment?['pet'] ?? '—'),
                          _infoRow('Type', _appointment?['type'] ?? '—'),
                          _infoRow('Status', _appointment?['status'] ?? '—'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _SectionCard(
                        title: 'Schedule',
                        children: [
                          _infoRow('Date', _formatDate(_appointment!)),
                          _infoRow('Time', _formatTime(_appointment!)),
                          _infoRow(
                            'Duration',
                            _appointment?['duration'] ?? '—',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _SectionCard(
                        title: 'Owner',
                        children: [
                          _infoRow('Name', _ownerName),
                          _infoRow('Phone', _ownerPhone),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _SectionCard(
                        title: 'Clinic',
                        children: [_infoRow('Name', _clinicName)],
                      ),
                      const SizedBox(height: 16),

                      _SectionCard(
                        title: 'Notes',
                        children: [
                          Text(
                            (_appointment?['notes'] ??
                                    _appointment?['reason'] ??
                                    '—')
                                .toString(),
                            style: TextStyle(
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
