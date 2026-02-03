import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditOwnerProfile extends StatefulWidget {
  const EditOwnerProfile({super.key});

  @override
  State<EditOwnerProfile> createState() => _EditOwnerProfileState();
}

class _EditOwnerProfileState extends State<EditOwnerProfile> {
  /// Form key for validating form inputs before saving
  final _formKey = GlobalKey<FormState>();

  final _phoneCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  
  /// Loading state flags
  bool _isLoading = true;  // Shows loading indicator while fetching profile data
  bool _isSaving = false;  // Shows loading indicator while saving changes

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
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
                                Icons.person,
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
                      const Text(
                        'Personal information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Phone field with validation
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
                              validator: (v) => (v == null || v.isEmpty) ? 'Enter phone' : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Cancel button - disables while saving
                          Expanded(
                            child: OutlinedButton(
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

  Future<void> _loadProfile() async {
    final uid = _authService.currentUserId;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Get owner data from Firestore
    final data = await _authService.getUserData(uid);
    if (data != null) {
      _phoneCtrl.text = (data['phone'] as String?) ?? '';
    }

    // Mark loading as complete and rebuild UI
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Validates and saves the edited owner profile data to Firestore
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

    // Update owner profile in Firestore
    final success = await _authService.updateUserProfile(
      uid: uid,
      userType: 'owner',
      data: {'phone': _phoneCtrl.text.trim()},
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
