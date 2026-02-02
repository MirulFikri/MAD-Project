import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

class ActivityTrackingPage extends StatefulWidget {
  const ActivityTrackingPage({Key? key}) : super(key: key);

  @override
  State<ActivityTrackingPage> createState() => _ActivityTrackingPageState();
}

class _ActivityTrackingPageState extends State<ActivityTrackingPage> {
  String? selectedPet;
  List<String> petNames = [];
  int walksToday = 3;
  double distanceKm = 6.3;
  int activeTimeMin = 120;
  int selectedFilter = 0; // 0: All, 1: Walks, 2: Meals, 3: Exercise

  final List<Map<String, dynamic>> activities = [
    {
      'type': 'walk',
      'title': 'Morning Walk',
      'time': '7:30 AM',
      'duration': '30 min',
      'distance': '2.5 km',
      'icon': Icons.directions_walk,
      'iconColor': Color(0xFF6C7AFA),
    },
    {
      'type': 'meal',
      'title': 'Breakfast',
      'time': '8:00 AM',
      'amount': '250g',
      'icon': Icons.restaurant,
      'iconColor': Color(0xFF4DD786),
    },
    {
      'type': 'meal',
      'title': 'Lunch',
      'time': '1:00 PM',
      'amount': '300g',
      'icon': Icons.restaurant,
      'iconColor': Color(0xFF4DD786),
    },
  ];

  List<Map<String, dynamic>> get filteredActivities {
    if (selectedFilter == 0) return activities;
    if (selectedFilter == 1) return activities.where((a) => a['type'] == 'walk').toList();
    if (selectedFilter == 2) return activities.where((a) => a['type'] == 'meal').toList();
    if (selectedFilter == 3) return activities.where((a) => a['type'] == 'exercise').toList();
    return activities;
  }

  @override
  void initState() {
    super.initState();
    _fetchOwnerPets();
  }

  Future<void> _fetchOwnerPets() async {
    final auth = AuthService();
    final uid = auth.currentUserId;
    if (uid == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('pets')
        .where('ownerId', isEqualTo: uid)
        .get();
    final names = snapshot.docs.map((doc) => doc['name'] as String? ?? '').where((n) => n.isNotEmpty).toList();
    setState(() {
      petNames = names;
      if (petNames.isNotEmpty) {
        selectedPet = petNames.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Activity Tracking',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB), size: 30),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Pet Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('🐈', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedPet,
                            isExpanded: true,
                            underline: const SizedBox(),
                            borderRadius: BorderRadius.circular(12),
                            items: petNames
                                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => selectedPet = v);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatBox(
                        value: walksToday.toString(),
                        label: 'Walks today',
                        color: const Color(0xFF2563EB),
                      ),
                      _StatBox(
                        value: distanceKm.toString(),
                        label: 'Distance\nkm',
                        color: const Color(0xFF10B981),
                      ),
                      _StatBox(
                        value: activeTimeMin.toString(),
                        label: 'Active Time\nmin',
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Filter Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: selectedFilter == 0,
                        onTap: () => setState(() => selectedFilter = 0),
                      ),
                      _FilterChip(
                        label: 'Walks',
                        selected: selectedFilter == 1,
                        onTap: () => setState(() => selectedFilter = 1),
                      ),
                      _FilterChip(
                        label: 'Meals',
                        selected: selectedFilter == 2,
                        onTap: () => setState(() => selectedFilter = 2),
                      ),
                      _FilterChip(
                        label: 'Exercise',
                        selected: selectedFilter == 3,
                        onTap: () => setState(() => selectedFilter = 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('TODAY', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey)),
                  const SizedBox(height: 8),
                  // Activity List
                  ...filteredActivities.map((a) => _ActivityCard(activity: a)).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFF6F8FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final bool isWalk = activity['type'] == 'walk';
    final bool isMeal = activity['type'] == 'meal';
    final bool isExercise = activity['type'] == 'exercise';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (activity['iconColor'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity['icon'], color: activity['iconColor'], size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['time'],
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (isWalk) ...[
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(activity['duration'], style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 12),
                      const Icon(Icons.pin_drop, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 4),
                      Text(activity['distance'], style: const TextStyle(fontSize: 13)),
                    ],
                    if (isMeal) ...[
                      Text(activity['amount'], style: const TextStyle(fontSize: 13)),
                    ],
                    if (isExercise) ...[
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(activity['duration'], style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
