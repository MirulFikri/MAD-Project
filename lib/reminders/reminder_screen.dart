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

  // Initial Dummy Data so the screen isn't empty
  final List<Map<String, dynamic>> reminders = [
    {'id': 1, 'pet': 'Fufu', 'type': 'Feeding', 'time': '8.00 P.M'},
    {'id': 2, 'pet': 'Fufu', 'type': 'Medication', 'time': '5.30 P.M'},
    {'id': 3, 'pet': 'Bubu', 'type': 'Feeding', 'time': '7.00 P.M'},
    {'id': 4, 'pet': 'Bubu', 'type': 'Grooming', 'time': '10.00 A.M'},
  ];

  // Helper to switch images based on pet name
  // UPDATED: Now uses the "images/" path as requested
  String _getPetImage(String petName) {
    switch (petName) {
      case 'Fufu': return 'images/logo.png'; 
      case 'Bubu': return 'images/logo.png'; 
      case 'Oyen': return 'images/logo.png';
      default: return 'images/logo.png'; // Ensure you have a default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9), // Light Grey background
      appBar: AppBar(
        title: const Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: Stack(
        children: [
          // List of Reminders
          Padding(
            padding: const EdgeInsets.only(bottom: 120), // Leave space for the bottom button
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                return _buildReminderCard(index, reminders[index]);
              },
            ),
          ),
          
          // "Clear all reminders" Text
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
                child: const Text(
                  "Clear all reminders", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)
                ),
              ),
            ),
          ),
          
          // The Floating Add Button (Cyan +)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF00BCD4), // Cyan color
                  shape: const CircleBorder(),
                  elevation: 4,
                  onPressed: _showAddReminderDialog,
                  child: const Icon(Icons.add, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Single Reminder Card ---
  Widget _buildReminderCard(int index, Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEFE7), // Beige/Peach color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // Left Side: Pet Image + Name
              Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(_getPetImage(reminder['pet'])),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    reminder['pet'].toUpperCase(), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Right Side: Task Description
              Expanded(
                child: Text(
                  _buildCardText(reminder),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900, // Extra bold like the image
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          // Close (X) Button Top Right
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                NotificationService().cancelNotification(reminder['id']);
                setState(() {
                  reminders.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF222222), 
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildCardText(Map<String, dynamic> r) {
    // Formats text like: "Feed Fufu at 8.00 P.M"
    if (r['type'] == 'Medication') {
      return "Give Medication to ${r['pet']} at ${r['time']}";
    } else if (r['type'] == 'Grooming') {
      return "Grooming appointment today at ${r['time']}";
    }
    return "${r['type']} ${r['pet']} today at ${r['time']}";
  }

  // --- DIALOG: Add New Reminder ---
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
            return Dialog(
              backgroundColor: const Color(0xFFFCEFE7), // Match the beige card color
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close X Button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          radius: 14, 
                          backgroundColor: Color(0xFF222222), 
                          child: Icon(Icons.close, size: 16, color: Colors.white)
                        ),
                      ),
                    ),
                    
                    const Text(
                      "Create a new Reminder", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                    ),
                    const SizedBox(height: 25),

                    // Form Fields
                    _buildDialogRow("Choose pet :", 
                      _buildDropdown(selectedPet, myPets, "Choose pet...", (val) => setDialogState(() => selectedPet = val))
                    ),
                    _buildDialogRow("Choose Type :", 
                      _buildDropdown(selectedType, ["Feeding", "Medication", "Grooming"], "Choose type...", (val) => setDialogState(() => selectedType = val))
                    ),
                    _buildDialogRow("Time :", 
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) setDialogState(() => selectedTime = time);
                        },
                        child: _buildInputBox(
                          child: Text(
                            selectedTime == null ? "e.g : 12.00 A.M" : selectedTime!.format(context),
                            style: TextStyle(color: selectedTime == null ? Colors.grey[600] : Colors.black, fontSize: 13),
                          )
                        ),
                      )
                    ),
                    _buildDialogRow("Remind me :", 
                       _buildDropdown(selectedRemindMe, ["10 mins before", "30 mins before", "1 hour before"], "Choose time...", (val) => setDialogState(() => selectedRemindMe = val))
                    ),
                    _buildDialogRow("Repeat :", 
                       _buildDropdown(selectedRepeat, ["Everyday", "Never", "Weekends"], "Choose day...", (val) => setDialogState(() => selectedRepeat = val))
                    ),

                    const SizedBox(height: 25),
                    
                    // Green Check Button
                    GestureDetector(
                      onTap: () {
                        if (selectedPet != null && selectedType != null && selectedTime != null) {
                          _addReminder(selectedPet!, selectedType!, selectedTime!);
                          Navigator.pop(context);
                        }
                      },
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF6CC57C), // Green
                        child: Icon(Icons.check, color: Colors.white, size: 30),
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

  // --- LOGIC: Add Reminder ---
  void _addReminder(String pet, String type, TimeOfDay time) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

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

  // --- HELPERS: Dialog Widgets ---
  
  // Row for "Label : Input"
  Widget _buildDialogRow(String label, Widget input) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(
            width: 160, // Fixed width for alignment
            height: 35,
            child: input,
          ),
        ],
      ),
    );
  }

  // Grey Box Container
  Widget _buildInputBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.transparent),
      ),
      child: child,
    );
  }

  // Custom Dropdown
  Widget _buildDropdown(String? value, List<String> items, String hint, Function(String?) onChanged) {
    return _buildInputBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
          hint: Text(hint, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}