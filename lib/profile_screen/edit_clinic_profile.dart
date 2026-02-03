import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditClinicProfile extends StatefulWidget {
  const EditClinicProfile({super.key});

  @override
  State<EditClinicProfile> createState() => _EditClinicProfileState();
}

class _EditClinicProfileState extends State<EditClinicProfile> {
  /// Form key for validating form inputs before saving
  final _formKey = GlobalKey<FormState>();
  
  /// Text controllers for managing form field inputs
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  /// Set of selected services offered by the clinic
  Set<String> _selectedServices = {};
  
  /// Loading state flags
  bool _isLoading = true;  // Shows loading indicator while fetching profile data
  bool _isSaving = false;  // Shows loading indicator while saving changes

  @override
  void initState() {
    super.initState();
    // Load existing clinic profile data from Firestore
    _loadProfile();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFEFF7FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.blue.shade50,
                              child: const Icon(
                                Icons.local_hospital,
                                size: 48,
                                color: Colors.blue,
                              ),
                            ),
                            // Edit button overlay on avatar
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    // TODO: implement image picker
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      // --- CLINIC INFORMATION SECTION ---
                      const Text(
                        'Clinic information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Form for editing clinic details with validation
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _phoneCtrl,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone_outlined),
                                labelText: 'Phone',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              // Make syre phone field is not empty
                              validator: (v) => (v == null || v.isEmpty) ? 'Enter phone' : null,
                            ),
                            const SizedBox(height: 12),
                            // Address field (multi-line)
                            TextFormField(
                              controller: _addressCtrl,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.location_on_outlined,
                                ),
                                labelText: 'Address',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              maxLines: 2,
                              validator: (v) => (v == null || v.isEmpty) ? 'Enter address' : null,
                            ),
                            const SizedBox(height: 12),
                            // Operating hours field
                            TextFormField(
                              controller: _hoursCtrl,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.access_time),
                                labelText: 'Hours',
                                hintText: 'e.g., Mon-Fri 9AM-5PM',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Let clinic select which services they offer
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Display services as selectable tags/chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: commonVetServices.map((service) {
                          final isSelected = _selectedServices.contains(
                            service,
                          );
                          return FilterChip(
                            label: Text(service),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedServices.add(service);
                                } else {
                                  _selectedServices.remove(service);
                                }
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.blue.shade200,
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),
                      // --- ACTION BUTTONS ---
                      Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: OutlinedButton(
                              // Disable button while saving
                              onPressed: _isSaving ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text('Save Changes'),
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

  /// Loads the clinic's existing profile data from Firestore
  Future<void> _loadProfile() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Get clinic data from Firestore
    final data = await _authService.getUserData(uid);
    if (data != null) {
      // Populate form fields with existing data
      _phoneCtrl.text = (data['phone'] as String?) ?? '';
      _addressCtrl.text = (data['address'] as String?) ?? '';
      _hoursCtrl.text = (data['hours'] as String?) ?? '';
      final services = data['services'] as List<dynamic>?;
      _selectedServices = (services ?? []).cast<String>().toSet();
    }

    // Mark loading as complete and rebuild UI
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Validates and saves the edited clinic profile data to Firestore
  Future<void> _save() async {
    // Validate form inputs before saving
    if (!_formKey.currentState!.validate()) return;

    final uid = _authService.currentUserId;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user is signed in.')));
      return;
    }

    // Show loading indicator
    setState(() => _isSaving = true);

    // Update clinic profile in Firestore
    final success = await _authService.updateUserProfile(
      uid: uid,
      userType: 'clinic',
      data: {
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'hours': _hoursCtrl.text.trim(),
        'services': _selectedServices.toList(),
      },
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    // Show result message and navigate back if successful
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }
}
