import 'package:flutter/material.dart';
import 'package:petcare_app/owner_homescreen/add_pet.dart';
import 'package:petcare_app/profile_screen/pet_profile.dart';
import 'package:petcare_app/services/auth_service.dart';

// Placeholder screens - create these files later
class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final AuthService _authService = AuthService();
  String _ownerName = '';

  @override
  void initState() {
    super.initState();
    _loadOwnerData();
  }

  Future<void> _loadOwnerData() async {
    final uid = _authService.currentUserId;
    if (uid != null) {
      final userData = await _authService.getUserData(uid);
      if (mounted && userData != null) {
        setState(() {
          _ownerName = (userData['name'] as String?) ?? 'Guest';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome Back, ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          TextSpan(
                            text: _ownerName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[400],
                            ),
                          ),
                          TextSpan(
                            text: '!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your pets with ease',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Navigation Cards Grid (two cards on top, one centered below)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double spacing = 16; // same as original spacing
                    final double cellWidth =
                        (constraints.maxWidth - spacing) / 2;
                    return Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: cellWidth,
                              child: _NavigationCard(
                                icon: Icons.pets,
                                label: 'Pet Profile',
                                color: Colors.blue[400]!,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PetProfile(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: cellWidth,
                              child: _NavigationCard(
                                icon: Icons.trending_up,
                                label: 'Activity Tracking',
                                color: Colors.green[400]!,
                                onTap: () {
                                  // Navigate to activity tracking
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: cellWidth,
                            child: _NavigationCard(
                              icon: Icons.add_circle_outline,
                              label: 'Add Pet',
                              color: Colors.purple[400]!,
                              onTap: () => _showAddPetDialog(context),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AddPetModal(),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
