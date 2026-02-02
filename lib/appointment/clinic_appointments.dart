import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';
import 'package:petcare_app/appointment/appointment_details.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool calendarMode = false;
  String statusFilter = 'All';
  DateTime selectedMonth = DateTime.now();
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      setState(() {
        appointments = [];
        _isLoading = false;
      });
      return;
    }
    final query = _firestore
        .collection('appointments')
        .where('clinicId', isEqualTo: uid);
    final snapshot = await query.get();
    setState(() {
      appointments = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
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

            const SizedBox(height: 8),

            // Toggle and tabs
            Row(
              children: [
                ToggleButtons(
                  isSelected: [!calendarMode, calendarMode],
                  onPressed: (i) => setState(() => calendarMode = i == 1),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('List'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Calendar'),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Confirmed', 'Pending', 'Urgent']
                          .map<Widget>(
                            (t) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(t),
                                selected: statusFilter == t,
                                onSelected: (_) =>
                                    setState(() => statusFilter = t),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: calendarMode ? _buildCalendarView() : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final filtered = statusFilter == 'All'
        ? appointments
        : appointments.where((a) => a['status'] == statusFilter).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('No appointments found.'));
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final a = filtered[i];
        final ownerId = a['ownerId'] ?? '';

        DateTime? dateTime;
        if (a['dateTime'] != null) {
          dateTime = a['dateTime'] is Timestamp
              ? (a['dateTime'] as Timestamp).toDate()
              : (a['dateTime'] as DateTime);
        }
        final dateStr = dateTime != null
            ? '${dateTime.month}/${dateTime.day}/${dateTime.year}'
            : (a['date'] ?? '');
        final timeStr = dateTime != null
            ? TimeOfDay.fromDateTime(dateTime).format(context)
            : (a['time'] ?? '');

        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('owners').doc(ownerId).get(),
          builder: (context, ownerSnapshot) {
            String ownerName = 'Unknown Owner';
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
            }

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsScreen(
                    appointmentId: a['id'],
                    appointmentData: a,
                  ),
                ),
              ),
              child: _AppointmentCard(
                id: a['id'],
                date: dateStr,
                time: timeStr,
                pet: a['pet'] ?? '',
                ownerName: ownerName,
                type: a['type'] ?? '',
                status: a['status'] ?? 'Pending',
                onStatusChange: (status) async {
                  await _firestore.collection('appointments').doc(a['id']).update(
                    {'status': status},
                  );
                  await _loadAppointments();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarView() {
    // Simple month header + grid placeholder
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(
                () => selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month - 1,
                ),
              ),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${_monthName(selectedMonth.month)} ${selectedMonth.year}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: () => setState(
                () => selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month + 1,
                ),
              ),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: 35,
            itemBuilder: (_, i) => Card(
              margin: const EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${i + 1}'),
                    const Spacer(),
                    if (i % 7 == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '2 appts',
                          style: TextStyle(fontSize: 10, color: Colors.blue),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _openCreateAppointment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _CreateAppointmentForm(
          onCreate: (map) async {
            final clinicId = _authService.currentUserId;
            if (clinicId == null) return;

            try {
              // Save appointment to Firestore
              await _firestore.collection('appointments').add({
                'clinicId': clinicId,
                'ownerId': map['ownerId'],
                'petId': map['petId'],
                'pet': map['petName'],
                'type': map['type'],
                'dateTime': map['dateTime'],
                'notes': map['notes'],
                'status': 'Confirmed',
                'createdAt': FieldValue.serverTimestamp(),
              });

              // Add clinic to pet's treatingClinics array
              await _firestore.collection('pets').doc(map['petId']).update({
                'treatingClinics': FieldValue.arrayUnion([clinicId]),
              });

              await _loadAppointments();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment created successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class _CreateAppointmentForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onCreate;
  const _CreateAppointmentForm({required this.onCreate});

  @override
  State<_CreateAppointmentForm> createState() => _CreateAppointmentFormState();
}

class _CreateAppointmentFormState extends State<_CreateAppointmentForm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedOwner;
  String? _selectedPet;
  String? _selectedType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _notesController = TextEditingController();

  List<Map<String, dynamic>> _owners = [];
  List<Map<String, dynamic>> _pets = [];
  bool _loadingOwners = true;
  bool _loadingPets = false;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadOwners() async {
    try {
      final snapshot = await _firestore.collection('owners').get();
      setState(() {
        _owners = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['fullName'] ?? data['name'] ?? 'Unknown',
          };
        }).toList();
        _loadingOwners = false;
      });
    } catch (e) {
      setState(() => _loadingOwners = false);
    }
  }

  Future<void> _loadPetsForOwner(String ownerId) async {
    setState(() {
      _loadingPets = true;
      _selectedPet = null;
    });

    try {
      final snapshot = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: ownerId)
          .get();
      
      setState(() {
        _pets = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown Pet',
          };
        }).toList();
        _loadingPets = false;
      });
    } catch (e) {
      setState(() {
        _pets = [];
        _loadingPets = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedOwner == null || _selectedPet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select owner and pet')),
        );
        return;
      }
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')),
        );
        return;
      }

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final petName = _pets.firstWhere(
        (p) => p['id'] == _selectedPet,
        orElse: () => {'name': 'Unknown'},
      )['name'];

      widget.onCreate({
        'ownerId': _selectedOwner,
        'petId': _selectedPet,
        'petName': petName,
        'type': _selectedType ?? 'Checkup',
        'dateTime': Timestamp.fromDate(dateTime),
        'notes': _notesController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Appointment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Owner dropdown
              if (_loadingOwners)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Owner',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  value: _selectedOwner,
                  items: _owners.map((owner) {
                    return DropdownMenuItem(
                      value: owner['id'] as String?,
                      child: Text(owner['name'] as String? ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedOwner = value);
                    if (value != null) _loadPetsForOwner(value);
                  },
                  validator: (v) => v == null ? 'Select an owner' : null,
                ),
              const SizedBox(height: 16),

              // Pet dropdown
              if (_loadingPets)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Pet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pets),
                  ),
                  value: _selectedPet,
                  items: _pets.map((pet) {
                    return DropdownMenuItem(
                      value: pet['id'] as String?,
                      child: Text(pet['name'] as String? ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedPet = value),
                  validator: (v) => v == null ? 'Select a pet' : null,
                ),
              const SizedBox(height: 16),

              // Type dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Appointment Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                value: _selectedType,
                items: ['Checkup', 'Vaccination', 'Surgery', 'Emergency', 'Grooming']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (v) => v == null ? 'Select a type' : null,
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                ),
                leading: const Icon(Icons.calendar_today),
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // Time picker
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : _selectedTime!.format(context),
                ),
                leading: const Icon(Icons.access_time),
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                onTap: _pickTime,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Create Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String id;
  final String date;
  final String time;
  final String pet;
  final String ownerName;
  final String type;
  final String status;
  final void Function(String status) onStatusChange;
  const _AppointmentCard({
    required this.id,
    required this.date,
    required this.time,
    required this.pet,
    required this.ownerName,
    required this.type,
    required this.status,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pet — $type',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(ownerName, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (status == 'Pending') ...[
              ElevatedButton(
                onPressed: () => onStatusChange('Confirmed'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Accept'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => onStatusChange('Declined'),
                child: const Text('Decline'),
              ),
            ] else ...[
              Text(
                status,
                style: TextStyle(
                  color: status == 'Confirmed' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
