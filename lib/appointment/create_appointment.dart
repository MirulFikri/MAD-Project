import 'package:flutter/material.dart';
import 'package:petcare_app/models/appointment_status.dart';
// id generation uses timestamp to avoid external dependency

class CreateAppointmentPage extends StatefulWidget {
  final Function(Appointment)? onAppointmentCreated;
  const CreateAppointmentPage({super.key, this.onAppointmentCreated});

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _petController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _reasonController = TextEditingController();
  
  String? _selectedType;

  @override
  void dispose() {
    _petController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Appointment'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pet Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _petController,
                decoration: InputDecoration(
                  labelText: 'Pet Name',
                  hintText: 'Enter pet name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.pets),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerController,
                decoration: InputDecoration(
                  labelText: 'Owner Name',
                  hintText: 'Enter owner name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Appointment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Appointment Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'Check-up', child: Text('Check-up')),
                  DropdownMenuItem(value: 'Vaccination', child: Text('Vaccination')),
                  DropdownMenuItem(value: 'Dental', child: Text('Dental')),
                  DropdownMenuItem(value: 'Surgery Consultation', child: Text('Surgery Consultation')),
                  DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
                  DropdownMenuItem(value: 'Lab Test', child: Text('Lab Test')),
                ],
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: 'Select date',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2026, 12, 31),
                  );
                  if (picked != null) _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                },
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Time',
                  hintText: 'Select time',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.access_time),
                ),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (picked != null) _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                },
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for Visit',
                  hintText: 'Enter reason or notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final dateTime = DateTime.parse(_dateController.text);
                      final timeParts = _timeController.text.split(':');
                      final appointment = Appointment(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        petName: _petController.text,
                        ownerName: _ownerController.text,
                        phone: _phoneController.text,
                        type: _selectedType!,
                        date: dateTime,
                        time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
                        reason: _reasonController.text,
                        status: 'Confirmed',
                      );
                      widget.onAppointmentCreated?.call(appointment);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment created successfully!')));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Create Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
