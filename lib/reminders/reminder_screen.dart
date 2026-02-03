import 'package:flutter/material.dart';
import 'package:petcare_app/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // We don't need a local 'reminders' list anymore because StreamBuilder handles it!

  // --- 1. Helper for Pet Images ---
  String _getPetImage(String petName) {
    // Basic logic to match names to assets
    String name = petName.toLowerCase().trim();
    if (name.contains('fufu')) return 'images/fufu.png';
    if (name.contains('bubu')) return 'images/bubu.png';
    if (name.contains('oyen')) return 'images/oyen.png';
    // Default fallback
    return 'images/cat_placeholder.png';
  }

  // --- 2. Helper for Pet Dropdown Query ---
  Query<Map<String, dynamic>> _petQuery() {
    final user = FirebaseAuth.instance.currentUser;
    final base = FirebaseFirestore.instance.collection('pets');
    if (user == null) return base;
    return base.where('ownerId', isEqualTo: user.uid);
  }

  List<String> _extractPetNames(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final pets = <String>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final name = (data['name'] ?? data['petName'])?.toString().trim();
      if (name != null && name.isNotEmpty) pets.add(name);
    }
    return pets;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FF),
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // --- 3. THE "TABLE" (List of Reminders) ---
          // Using StreamBuilder for real-time updates
          if (user != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reminders')
                  .where(
                    'ownerId',
                    isEqualTo: user.uid,
                  ) // Filter by current user
                  .orderBy(
                    'scheduledAt',
                    descending: false,
                  ) // Sort by time (Soonest first)
                  .snapshots(),
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error State (Likely Index missing)
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Need Index! Check your debug console for the link.\nError: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                // Empty State
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No reminders yet',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                // Data List
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 120,
                    left: 20,
                    right: 20,
                    top: 10,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    // Pass the Doc ID so we can delete it easily
                    return _buildReminderCard(docs[index].id, data);
                  },
                );
              },
            ),

          // "Clear all reminders" Button
          Positioned(
            bottom: 100,
            right: 20,
            left: 20,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _showClearAllDialog();
                },
                child: const Text(
                  'Clear all reminders',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // The Floating Add Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF00BCD4),
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
  Widget _buildReminderCard(String docId, Map<String, dynamic> reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEFE7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
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
                    backgroundImage: AssetImage(
                      _getPetImage(reminder['pet'] ?? ''),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (reminder['pet'] ?? '').toString().toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Right Side: Task Description
              Expanded(
                child: Text(
                  _buildCardText(reminder),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
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
              onTap: () => _deleteReminder(docId, reminder),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF222222),
                  shape: BoxShape.circle,
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
    final type = r['type'] ?? '';
    final pet = r['pet'] ?? '';
    final time = r['time'] ?? '';

    // Extract date from scheduledAt Timestamp if available
    String dateStr = '';
    if (r['scheduledAt'] != null) {
      try {
        final timestamp = r['scheduledAt'] as Timestamp;
        final dateTime = timestamp.toDate();
        final today = DateTime.now();

        // Check if the appointment is today
        if (dateTime.year == today.year &&
            dateTime.month == today.month &&
            dateTime.day == today.day) {
          dateStr = 'today';
        } else {
          dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
        }
      } catch (e) {
        dateStr = '';
      }
    }

    final dateDisplay = dateStr.isNotEmpty ? ' on $dateStr' : '';

    if (type == 'Medication')
      return "Give Medication to $pet at $time$dateDisplay";
    if (type == 'Grooming') return "Grooming appointment at $time$dateDisplay";
    return "$type $pet at $time$dateDisplay";
  }

  // --- LOGIC: Delete Single Reminder ---
  Future<void> _deleteReminder(String docId, Map<String, dynamic> data) async {
    try {
      // 1. Delete from Firestore
      await FirebaseFirestore.instance
          .collection('reminders')
          .doc(docId)
          .delete();

      // 2. Cancel Local Notifications (both the appointment and 1-day-before)
      if (data['notificationId'] != null) {
        NotificationService().cancelNotification(data['notificationId']);
      }
      if (data['notificationIdOneDayBefore'] != null) {
        NotificationService().cancelNotification(
          data['notificationIdOneDayBefore'],
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
    }
  }

  // --- DIALOG: Clear All ---
  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Reminders?'),
        content: const Text('Are you sure you want to delete all reminders?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              // Get all docs for this user and delete them
              final snapshot = await FirebaseFirestore.instance
                  .collection('reminders')
                  .where('ownerId', isEqualTo: user.uid)
                  .get();

              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG: Add New Reminder (Same as before) ---
  void _showAddReminderDialog() {
    String? selectedPet;
    String? selectedType;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String? selectedRemindMe;
    String? selectedRepeat;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFFFCEFE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFF222222),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      "Create a new Reminder",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildDialogRow(
                      "Choose pet :",
                      _buildPetDropdown(
                        selectedPet,
                        (val) => setDialogState(() => selectedPet = val),
                      ),
                    ),
                    _buildDialogRow(
                      "Choose Type :",
                      _buildDropdown(
                        selectedType,
                        ["Feeding", "Medication", "Grooming"],
                        "Choose type...",
                        (val) => setDialogState(() => selectedType = val),
                      ),
                    ),

                    _buildDialogRow(
                      "Date :",
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null)
                            setDialogState(() => selectedDate = date);
                        },
                        child: _buildInputBox(
                          child: Text(
                            selectedDate == null
                                ? "e.g : 02/02/2026"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            style: TextStyle(
                              color: selectedDate == null
                                  ? Colors.grey[600]
                                  : Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),

                    _buildDialogRow(
                      "Time :",
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null)
                            setDialogState(() => selectedTime = time);
                        },
                        child: _buildInputBox(
                          child: Text(
                            selectedTime == null
                                ? "e.g : 12.00 A.M"
                                : selectedTime!.format(context),
                            style: TextStyle(
                              color: selectedTime == null
                                  ? Colors.grey[600]
                                  : Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),

                    _buildDialogRow(
                      "Remind me :",
                      _buildDropdown(
                        selectedRemindMe,
                        [
                          "2 mins before",
                          "5 mins before",
                          "10 mins before",
                          "15 mins before",
                          "20 mins before",
                          "30 mins before",
                          "1 hour before",
                          "1 day before"
                        ],
                        "Choose time...",
                        (val) => setDialogState(() => selectedRemindMe = val),
                      ),
                    ),
                    _buildDialogRow(
                      "Repeat :",
                      _buildDropdown(
                        selectedRepeat,
                        ["Everyday", "Never"],
                        "Choose day...",
                        (val) => setDialogState(() => selectedRepeat = val),
                      ),
                    ),

                    const SizedBox(height: 25),

                    GestureDetector(
                      onTap: () {
                        print('Add button tapped');
                        print('selectedPet: $selectedPet');
                        print('selectedType: $selectedType');
                        print('selectedDate: $selectedDate');
                        print('selectedTime: $selectedTime');
                        print('selectedRepeat: $selectedRepeat');
                        
                        if (selectedPet != null &&
                            selectedType != null &&
                            selectedDate != null &&
                            selectedTime != null) {
                          // Validate that the scheduled date/time is in the future
                          final scheduledDateTime = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );

                          print('scheduledDateTime: $scheduledDateTime');
                          print('now: ${DateTime.now()}');
                          print('isBefore: ${scheduledDateTime.isBefore(DateTime.now())}');

                          // Show error only if time is past AND repeat is "Never"
                          if (scheduledDateTime.isBefore(DateTime.now()) &&
                              selectedRepeat == "Never") {
                            // Show error dialog for past date/time with Never repeat
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Invalid Date/Time'),
                                  content: const Text(
                                    'The reminder date and time cannot be in the past when repeat is set to "Never". Please select a future date and time.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Proceed with adding reminder
                            _addReminder(
                              selectedPet!,
                              selectedType!,
                              selectedDate!,
                              selectedTime!,
                              remindMe: selectedRemindMe,
                              repeat: selectedRepeat,
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF6CC57C),
                        child: Icon(Icons.check, color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- LOGIC: Add Reminder to Firestore ---
  Future<void> _addReminder(
    String pet,
    String type,
    DateTime date,
    TimeOfDay time, {
    String? remindMe,
    String? repeat,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    var scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final reminderBeforeId = id + 1; // Unique ID for the reminder-before notification

    // 1. Schedule Local Notification for the actual appointment
    NotificationService().scheduleNotification(
      id: id,
      title: 'PetCare',
      body: '$pet has $type appointment at ${time.format(context)} ‼️',
      scheduledTime: scheduledDate,
    );

    // 2. Schedule notification based on "Remind me" selection
    if (remindMe != null && remindMe.isNotEmpty) {
      DateTime reminderTime;
      
      // Parse the remind me option and calculate the notification time
      if (remindMe == "2 mins before") {
        reminderTime = scheduledDate.subtract(const Duration(minutes: 2));
      } else if (remindMe == "5 mins before") {
        reminderTime = scheduledDate.subtract(const Duration(minutes: 5));
      } else if (remindMe == "10 mins before") {
        reminderTime = scheduledDate.subtract(const Duration(minutes: 10));
      } else if (remindMe == "15 mins before") {
        reminderTime = scheduledDate.subtract(const Duration(minutes: 15));
      } else if (remindMe == "20 mins before") {
        reminderTime = scheduledDate.subtract(const Duration(minutes: 20));
      } else if (remindMe == "30 mins before") {
        reminderTime = scheduledDate.subtract(const Duration(minutes: 30));
      } else if (remindMe == "1 hour before") {
        reminderTime = scheduledDate.subtract(const Duration(hours: 1));
      } else if (remindMe == "1 day before") {
        reminderTime = scheduledDate.subtract(const Duration(days: 1));
      } else {
        // Default to 1 day before if not recognized
        reminderTime = scheduledDate.subtract(const Duration(days: 1));
      }

      // Only schedule if the reminder time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
          id: reminderBeforeId,
          title: 'PetCare Reminder',
          body: 'Reminder: $pet has $type appointment at ${time.format(context)} ‼️',
          scheduledTime: reminderTime,
        );
      }
    }

    // 3. Add to Firestore
    // Note: We use 'scheduledAt' for sorting, and 'createdAt' for auditing
    await FirebaseFirestore.instance.collection('reminders').add({
      'ownerId': user.uid,
      'pet': pet,
      'type': type,
      'time': time.format(context),
      'scheduledAt': Timestamp.fromDate(scheduledDate),
      'createdAt': FieldValue.serverTimestamp(),
      'notificationId': id, // Save this so we can cancel the alarm later
      'notificationIdOneDayBefore': reminderBeforeId, // Save the reminder-before notification ID
      'remindMe': remindMe,
      'repeat': repeat,
    });
  }

  // --- HELPERS ---
  Widget _buildDialogRow(String label, Widget input) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(width: 160, height: 35, child: input),
        ],
      ),
    );
  }

  Widget _buildInputBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }

  Widget _buildDropdown(
    String? value,
    List<String> items,
    String hint,
    Function(String?) onChanged,
  ) {
    return _buildInputBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Colors.grey,
          ),
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          items: items
              .map(
                (val) => DropdownMenuItem(
                  value: val,
                  child: Text(val, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPetDropdown(String? value, Function(String?) onChanged) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _petQuery().snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return _buildInputBox(
            child: Text(
              "Loading...",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          );
        final pets = _extractPetNames(snapshot.data!);
        return _buildDropdown(value, pets, 'Choose pet...', onChanged);
      },
    );
  }
}
