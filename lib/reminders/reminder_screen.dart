import 'package:flutter/material.dart';
import 'package:petcare_app/services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // Dummy data to simulate your "Pets"
  final List<String> myPets = ['Fufu', 'Bubu', 'Oyen']; 
  final List<Map<String, dynamic>> reminders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9), // Grey background from design
      appBar: AppBar(
        title: const Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // List of Reminders
          ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _buildReminderCard(index, reminder);
            },
          ),
          
          // The Bottom "Clear all" text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    reminders.clear();
                  });
                },
                child: const Text("Clear all reminders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
          
          // The Floating Add Button (Cyan +)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.cyan,
                onPressed: _showAddReminderDialog,
                child: const Icon(Icons.add, color: Colors.white, size: 35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the Reminder Card UI
  Widget _buildReminderCard(int index, Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEFE7), // The beige/pink color
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // Circular Pet Image Placeholder
              Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/cat_placeholder.png'), // Ensure you have an asset or use NetworkImage
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 4),
                  Text(reminder['pet'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 15),
              // Reminder Text
              Expanded(
                child: Text(
                  "${reminder['type']} for ${reminder['pet']} at ${reminder['time']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          // Close (X) Button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // Cancel notification and remove from list
                NotificationService().cancelNotification(reminder['id']);
                setState(() {
                  reminders.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The "Create a new Reminder" Dialog
  void _showAddReminderDialog() {
    String? selectedPet;
    String? selectedType;
    TimeOfDay? selectedTime;
    String? selectedRemindMe;
    String? selectedRepeat;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFCEFE7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close X on dialog
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.black87, child: Icon(Icons.close, size: 14, color: Colors.white)),
                      ),
                    ),
                    const Text("Create a new Reminder", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 20),

                    // Dropdowns (Pet, Type, Time, etc.)
                    _buildDropdownRow("Choose pet :", selectedPet, myPets, (val) => setDialogState(() => selectedPet = val)),
                    _buildDropdownRow("Choose Type :", selectedType, ["Feeding", "Medication", "Grooming"], (val) => setDialogState(() => selectedType = val)),
                    
                    // Time Picker Row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Time :", style: TextStyle(fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () async {
                              final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (time != null) setDialogState(() => selectedTime = time);
                            },
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                selectedTime == null ? "e.g : 12.00 A.M" : selectedTime!.format(context),
                                style: TextStyle(color: selectedTime == null ? Colors.grey : Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildDropdownRow("Remind me :", selectedRemindMe, ["10 mins before", "30 mins before"], (val) => setDialogState(() => selectedRemindMe = val)),
                    _buildDropdownRow("Repeat :", selectedRepeat, ["Everyday", "Never"], (val) => setDialogState(() => selectedRepeat = val)),

                    const SizedBox(height: 20),
                    // Green Checkmark Button
                    GestureDetector(
                      onTap: () {
                        if (selectedPet != null && selectedType != null && selectedTime != null) {
                          _addReminder(selectedPet!, selectedType!, selectedTime!);
                          Navigator.pop(context);
                        }
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF6CC57C), // Green color
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Logic to Add Data & Schedule Notification
  void _addReminder(String pet, String type, TimeOfDay time) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000; // Unique ID

    // Schedule the system notification
    NotificationService().scheduleNotification(
      id: id,
      title: 'PetCare',
      body: '$pet has $type appointment at ${time.format(context)} ‼️',
      scheduledTime: scheduledDate,
    );

    setState(() {
      reminders.add({
        'id': id,
        'pet': pet,
        'type': type,
        'time': time.format(context),
      });
    });
  }

  // Widget Helper for Dialog Dropdowns
  Widget _buildDropdownRow(String label, String? currentValue, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                isExpanded: true,
                hint: Text("Select...", style: TextStyle(color: Colors.grey, fontSize: 12)),
                items: items.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
