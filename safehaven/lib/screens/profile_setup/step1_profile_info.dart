import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'step2_choose_role.dart';

class Step1ProfileInfo extends StatefulWidget {
  const Step1ProfileInfo({super.key});

  @override
  State<Step1ProfileInfo> createState() => _Step1ProfileInfoState();
}

class _Step1ProfileInfoState extends State<Step1ProfileInfo> {
  String gender = 'Female';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  /// ✅ Save user info locally before moving to Step 2
  Future<void> _saveProfileInfo() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', nameController.text.trim());
    await prefs.setString('city', cityController.text.trim());
    await prefs.setString('gender', gender);
    await prefs.setInt('age', int.tryParse(ageController.text.trim()) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Profile Setup',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('Step 1 of 2'),
                const SizedBox(height: 40),
                const Icon(Icons.account_circle, color: Colors.purple, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This helps us personalize your experience',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Full Name
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 20),

                // Age
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter your age';
                    final age = int.tryParse(value);
                    if (age == null || age <= 0 || age > 120) {
                      return 'Enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // City
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City of Residence',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your city'
                      : null,
                ),
                const SizedBox(height: 24),

                // Gender
                const Text(
                  'Gender',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Column(
                  children: ['Female', 'Male', 'Other'].map((g) {
                    return RadioListTile<String>(
                      title: Text(g),
                      value: g,
                      groupValue: gender,
                      onChanged: (val) {
                        setState(() {
                          gender = val!;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                  ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('name', nameController.text.trim());
                      await prefs.setString('city', cityController.text.trim());
                      await prefs.setInt('age', int.tryParse(ageController.text.trim()) ?? 0);
                      await prefs.setString('gender', gender);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Step2ChooseRole(gender: gender),
                        ),
                      );
                    }
                  },
                  child: const Text('Continue'),
                ),


                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
