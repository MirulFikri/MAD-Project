import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petcare_app/services/auth_service.dart';

class AddPetModal extends StatefulWidget {
  const AddPetModal({super.key});

  @override
  State<AddPetModal> createState() => _AddPetModalState();
}

class _AddPetModalState extends State<AddPetModal> {
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  String? _selectedGender;

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSaving = false;

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    // Validation
    if (_petNameController.text.isEmpty) {
      _showError('Please enter pet name');
      return;
    }
    if (_breedController.text.isEmpty) {
      _showError('Please enter breed');
      return;
    }
    if (_selectedGender == null) {
      _showError('Please select gender');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = _authService.currentUserId;
      if (uid == null) {
        _showError('No user logged in');
        return;
      }

      // Use pet name as document ID
      final petId = _petNameController.text.toLowerCase().replaceAll(' ', '_');

      await _firestore.collection('pets').doc(petId).set({
        'name': _petNameController.text.trim(),
        'breed': _breedController.text.trim(),
        'age': _ageController.text.trim(),
        'weight': _weightController.text.trim(),
        'height': _heightController.text.trim(),
        'gender': _selectedGender,
        'birthday': _birthdayController.text.trim(),
        'ownerId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_petNameController.text} added successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError('Error adding pet: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Pet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.close, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pet Name
                _buildTextField(
                  'Pet Name',
                  _petNameController,
                  'Enter pet name',
                ),
                const SizedBox(height: 16),

                // Breed
                _buildTextField('Breed', _breedController, 'Enter breed'),
                const SizedBox(height: 16),

                // Age
                _buildTextField('Age', _ageController, 'Enter age'),
                const SizedBox(height: 16),

                // Weight
                _buildTextField(
                  'Weight',
                  _weightController,
                  'Enter weight (kg)',
                ),
                const SizedBox(height: 16),

                // Height
                _buildTextField(
                  'Height',
                  _heightController,
                  'Enter height (cm)',
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: const Text('Select Gender'),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Birthday
                _buildTextField('Birthday', _birthdayController, 'DD/MM/YYYY'),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _savePet,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue[400],
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Add Pet',
                                style: TextStyle(color: Colors.white),
                              ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hintText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[400]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
