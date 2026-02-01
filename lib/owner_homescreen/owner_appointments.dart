import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

class OwnerAppointmentsPage extends StatefulWidget {
  const OwnerAppointmentsPage({super.key});

  @override
  State<OwnerAppointmentsPage> createState() => _OwnerAppointmentsPageState();
}

class _OwnerAppointmentsPageState extends State<OwnerAppointmentsPage> {
  List<Map<String, String>> appointments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          TextButton.icon(
            onPressed: () => _openCreateAppointment(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('New', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
              child: appointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('No appointments yet', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _openCreateAppointment(context),
                            child: const Text('Create Appointment'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (_, i) {
                        final a = appointments[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(a['time'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(a['duration'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            title: Text('${a['pet']} — ${a['type']}'),
                            subtitle: Text(a['vet'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(onPressed: () {}, child: const Text('View')),
                                const SizedBox(width: 8),
                                TextButton(onPressed: () => _cancelAppointment(i), child: const Text('Cancel')),
                              ],
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

  void _cancelAppointment(int index) {
    setState(() => appointments.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
  }

  void _openCreateAppointment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _CreateAppointmentForm(onCreate: (map) {
          setState(() => appointments.add(map));
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment created')));
        }),
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
  final TextEditingController vetController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  DateTime? _date;
  TimeOfDay? _time;
  String _type = 'Check-up';
  String? _selectedPetId;
  List<Map<String, dynamic>> _userPets = [];
  bool _isLoadingPets = true;

  @override
  void initState() {
    super.initState();
    _loadUserPets();
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
              const Text('New Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
                  decoration: const InputDecoration(labelText: 'Select Pet', prefixIcon: Icon(Icons.pets)),
                    items: _userPets
                      .map((pet) => DropdownMenuItem<String>(
                        value: pet['petId'] as String? ?? '',
                        child: Text(pet['name']?.toString() ?? 'Unknown Pet'),
                        ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPetId = value),
                  validator: (v) => (v == null) ? 'Please select a pet' : null,
                ),
              const SizedBox(height: 8),
              TextFormField(
                controller: vetController,
                decoration: const InputDecoration(labelText: 'Preferred vet/clinic', prefixIcon: Icon(Icons.local_hospital)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(_date == null ? 'Pick date' : '${_date!.month}/${_date!.day}/${_date!.year}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      child: Text(_time == null ? 'Pick time' : _time!.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Check-up', 'Vaccination', 'Surgery Consult', 'Grooming'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.note)),
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
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: 9, minute: 0));
    if (t != null) setState(() => _time = t);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final dateStr = _date != null ? '${_date!.month}/${_date!.day}/${_date!.year}' : 'TBD';
    final timeStr = _time != null ? _time!.format(context) : 'TBD';
    final selectedPet = _userPets.firstWhere((p) => p['petId'] == _selectedPetId, orElse: () => {});
    final petName = selectedPet['name'] ?? 'Unknown Pet';
    
    widget.onCreate({
      'pet': petName,
      'petId': _selectedPetId ?? '',
      'vet': vetController.text,
      'date': dateStr,
      'time': timeStr,
      'type': _type,
      'duration': '30m',
      'notes': notesController.text,
    });
  }

  @override
  void dispose() {
    vetController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
