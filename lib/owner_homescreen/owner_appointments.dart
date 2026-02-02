import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

class OwnerAppointmentsPage extends StatefulWidget {
  const OwnerAppointmentsPage({super.key});

  @override
  State<OwnerAppointmentsPage> createState() => _OwnerAppointmentsPageState();
}

class _OwnerAppointmentsPageState extends State<OwnerAppointmentsPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  String? _errorMsg;
  Future<void> _loadAppointments() async {
    final uid = _authService.currentUserId;
    print('[DEBUG] Current user UID: $uid');
    if (uid == null) {
      setState(() {
        appointments = [];
        _isLoading = false;
        _errorMsg = null;
      });
      return;
    }
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('ownerId', isEqualTo: uid)
          .orderBy('dateTime', descending: false)
          .limit(20)
          .get();
      print('[DEBUG] Appointments fetched:');
      for (var doc in snapshot.docs) {
        print(doc.data());
      }
      setState(() {
        appointments = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _isLoading = false;
        _errorMsg = null;
      });
    } catch (e) {
      print('[DEBUG] Error loading appointments: $e');
      setState(() {
        appointments = [];
        _isLoading = false;
        _errorMsg = 'Failed to load appointments. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateAppointment(context),
        tooltip: 'New Appointment',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search appointments',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMsg != null
                  ? Center(
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : appointments.isEmpty
                  ? const Center(child: Text('No appointments found'))
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (_, i) {
                        final a = appointments[i];
                        // Use dateTime (Timestamp) for display
                        String timeStr = '';
                        String dateStr = '';
                        if (a['dateTime'] != null) {
                          final dt = a['dateTime'] is Timestamp
                              ? (a['dateTime'] as Timestamp).toDate()
                              : (a['dateTime'] as DateTime);
                          timeStr = TimeOfDay.fromDateTime(dt).format(context);
                          dateStr = '${dt.month}/${dt.day}/${dt.year}';
                        } else {
                          timeStr = a['time'] ?? '';
                          dateStr = a['date'] ?? '';
                        }
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            title: Text('${a['pet']} — ${a['type']}'),
                            subtitle: Text(a['vet'] ?? ''),
                            trailing: TextButton(
                              onPressed: () => _cancelAppointment(i),
                              child: const Text('Cancel'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelAppointment(int index) async {
    final id = appointments[index]['id'];
    await _firestore.collection('appointments').doc(id).delete();
    await _loadAppointments();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
  }

  void _openCreateAppointment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _CreateAppointmentForm(
          onCreate: (map) async {
            final uid = _authService.currentUserId;
            if (uid == null) return;
            // Generate unique appointmentId (timestamp + uid)
            final appointmentId =
                '${DateTime.now().millisecondsSinceEpoch}_$uid';
            // Parse date and time to DateTime
            DateTime? dateTime;
            try {
              final dateParts = (map['date'] as String).split('/');
              final timeParts = (map['time'] as String).split(':');
              final hour = int.tryParse(timeParts[0]) ?? 9;
              final minute = int.tryParse(timeParts[1].split(' ')[0]) ?? 0;
              final isPM = (map['time'] ?? '').toLowerCase().contains('pm');
              int hour24 = hour;
              if (isPM && hour < 12) hour24 += 12;
              if (!isPM && hour == 12) hour24 = 0;
              dateTime = DateTime(
                DateTime.now().year, // fallback
                int.tryParse(dateParts[0]) ?? 1,
                int.tryParse(dateParts[1]) ?? 1,
                hour24,
                minute,
              );
            } catch (_) {
              dateTime = DateTime.now();
            }
            final appointment = {
              ...map,
              'ownerId': uid,
              'status': 'Pending',
              'createdAt': FieldValue.serverTimestamp(),
              'appointmentId': appointmentId,
              'dateTime': dateTime,
            };
            try {
              // Save appointment
              await _firestore
                  .collection('appointments')
                  .doc(appointmentId)
                  .set(appointment);

              // Add clinic to pet's treatingClinics array
              final petId = map['petId'] ?? '';
              final clinicId = map['clinicId'] ?? '';
              if (petId.isNotEmpty && clinicId.isNotEmpty) {
                await _firestore.collection('pets').doc(petId).update({
                  'treatingClinics': FieldValue.arrayUnion([clinicId]),
                });
              }

              Navigator.of(ctx).pop();
              await _loadAppointments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment created')),
              );
            } catch (e) {
              print('Error creating appointment: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
        ),
      ),
    );
  }
}

class _CreateAppointmentForm extends StatefulWidget {
  final void Function(Map<String, String>) onCreate;
  const _CreateAppointmentForm({required this.onCreate});

  @override
  State<_CreateAppointmentForm> createState() => _CreateAppointmentFormState();
}

class _CreateAppointmentFormState extends State<_CreateAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClinicId;
  List<Map<String, dynamic>> _clinics = [];
  final TextEditingController notesController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime? _date;
  TimeOfDay? _time;
  String _type = 'Check-up';
  String? _selectedPetId;
  List<Map<String, dynamic>> _userPets = [];
  bool _isLoadingPets = true;
  bool _isLoadingClinics = true;

  @override
  void initState() {
    super.initState();
    _loadUserPets();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    try {
      final clinics = await _authService.getAllClinics();
      setState(() {
        _clinics = clinics;
        _isLoadingClinics = false;
        if (clinics.isNotEmpty) {
          _selectedClinicId = clinics.first['uid'] as String?;
        }
      });
    } catch (e) {
      print('Error loading clinics: $e');
      setState(() => _isLoadingClinics = false);
    }
  }

  Future<void> _loadUserPets() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      setState(() => _isLoadingPets = false);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: uid)
          .get();

      final pets = snapshot.docs
          .map((doc) => {'petId': doc.id, 'name': doc.id, ...doc.data()})
          .toList();

      setState(() {
        _userPets = pets;
        _isLoadingPets = false;
        if (pets.isNotEmpty) {
          _selectedPetId = pets.first['petId'];
        }
      });
    } catch (e) {
      print('Error loading pets: $e');
      setState(() => _isLoadingPets = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New Appointment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (_isLoadingPets)
                const CircularProgressIndicator()
              else if (_userPets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('No pets found. Please add a pet first.'),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedPetId,
                  decoration: const InputDecoration(
                    labelText: 'Select Pet',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  items: _userPets
                      .map(
                        (pet) => DropdownMenuItem<String>(
                          value: pet['petId'] as String? ?? '',
                          child: Text(pet['name']?.toString() ?? 'Unknown Pet'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPetId = value),
                  validator: (v) => (v == null) ? 'Please select a pet' : null,
                ),
              const SizedBox(height: 8),
              if (_isLoadingClinics)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                )
              else if (_clinics.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('No clinics found.'),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedClinicId,
                  decoration: const InputDecoration(
                    labelText: 'Preferred vet/clinic',
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  items: _clinics
                      .map(
                        (clinic) => DropdownMenuItem<String>(
                          value: clinic['uid'] as String? ?? '',
                          child: Text(
                            clinic['clinicName']?.toString() ??
                                'Unknown Clinic',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedClinicId = value),
                  validator: (v) =>
                      (v == null) ? 'Please select a clinic' : null,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(
                        _date == null
                            ? 'Pick date'
                            : '${_date!.month}/${_date!.day}/${_date!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      child: Text(
                        _time == null ? 'Pick time' : _time!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                items:
                    ['Check-up', 'Vaccination', 'Surgery Consult', 'Grooming']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Appointment'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final dateStr = _date != null
        ? '${_date!.month}/${_date!.day}/${_date!.year}'
        : 'TBD';
    final timeStr = _time != null ? _time!.format(context) : 'TBD';
    final selectedPet = _userPets.firstWhere(
      (p) => p['petId'] == _selectedPetId,
      orElse: () => {},
    );
    final petName = selectedPet['name'] ?? 'Unknown Pet';

    final selectedClinic = _clinics.firstWhere(
      (c) => c['uid'] == _selectedClinicId,
      orElse: () => {},
    );
    final clinicName = selectedClinic['clinicName'] ?? 'Unknown Clinic';
    widget.onCreate({
      'pet': petName,
      'petId': _selectedPetId ?? '',
      'clinicId': _selectedClinicId ?? '',
      'vet': clinicName,
      'date': dateStr,
      'time': timeStr,
      'type': _type,
      'duration': '30m',
      'notes': notesController.text,
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}
