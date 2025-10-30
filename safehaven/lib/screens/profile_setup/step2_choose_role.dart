import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Step2ChooseRole extends StatefulWidget {
  final String gender;
  const Step2ChooseRole({super.key, required this.gender});

  @override
  State<Step2ChooseRole> createState() => _Step2ChooseRoleState();
}

class _Step2ChooseRoleState extends State<Step2ChooseRole> {
  bool isUserSelected = false;
  bool isVolunteerSelected = false;
  bool _isSaving = false;

  void _toggleRole(String role) {
    if (role == 'User / Victim' && widget.gender != 'Female') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only female users can register as User / Victim.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      if (role == 'User / Victim') {
        isUserSelected = !isUserSelected;
      } else if (role == 'Volunteer') {
        isVolunteerSelected = !isVolunteerSelected;
      }
    });
  }

  Future<void> _completeSetup() async {
    if (!isUserSelected && !isVolunteerSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one role.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();

    final roles = <String>[];
    if (isUserSelected) roles.add('User');
    if (isVolunteerSelected) roles.add('Volunteer');

    // ✅ Store role locally
    await prefs.setStringList('roles', roles);

    // ✅ Prepare full user data
    final userData = {
      'uid': prefs.getString('uid') ?? '', // optional if not signed in yet
      'email': prefs.getString('email') ?? '',
      'phone': prefs.getString('phone') ?? '',
      'name': prefs.getString('name'),
      'gender': prefs.getString('gender'),
      'city': prefs.getString('city'),
      'age': prefs.getInt('age'),
      'roles': roles,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // ✅ Upload to Firestore
    try {
       final userCollection = FirebaseFirestore.instance.collection('users');

      if (userData['uid'] != null &&
          userData['uid'].toString().isNotEmpty) {
        // If UID is available, use it as the document ID
        await userCollection
            .doc(userData['uid'].toString())
            .set(userData, SetOptions(merge: true));
      } else {
        // Otherwise, let Firestore generate an ID
        await userCollection.add(userData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile setup complete as ${roles.join(', ')}'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (isUserSelected && isVolunteerSelected) {
        Navigator.pushReplacementNamed(context, '/combined_home');
      } else if (isUserSelected) {
        Navigator.pushReplacementNamed(context, '/user_home');
      } else if (isVolunteerSelected) {
        Navigator.pushReplacementNamed(context, '/volunteer_home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildCheckboxRoleCard({
    required String role,
    required String description,
    required IconData icon,
    required bool value,
    required bool enabled,
    required VoidCallback onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: value ? Colors.blue.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? (_) => onChanged() : null,
              activeColor: Colors.blue,
            ),
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: value ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool userRoleEnabled = widget.gender == 'Female';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Profile Setup',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text('Step 2 of 2'),
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFFE8EAF6),
                child: Icon(Icons.shield, color: Colors.blue, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose your role',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you want to use SafeHaven',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              _buildCheckboxRoleCard(
                role: 'User / Victim',
                description:
                    'Access SOS features, send alerts, and get help when needed',
                icon: Icons.security,
                value: isUserSelected,
                enabled: userRoleEnabled,
                onChanged: () => _toggleRole('User / Victim'),
              ),

              _buildCheckboxRoleCard(
                role: 'Volunteer',
                description:
                    'Help others, respond to alerts, and provide assistance',
                icon: Icons.volunteer_activism,
                value: isVolunteerSelected,
                enabled: true,
                onChanged: () => _toggleRole('Volunteer'),
              ),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _completeSetup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Complete Setup',
                          style:
                              TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
