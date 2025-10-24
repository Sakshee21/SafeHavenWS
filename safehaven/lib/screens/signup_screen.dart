import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_input_field.dart';
import 'profile_setup/step1_profile_info.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUpUser() async {
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // Create user in Firebase Auth
      UserCredential userCred = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Store basic info in Firestore
     // Store basic info in Firestore
await firestore.collection('users').doc(userCred.user!.uid).set({
  'uid': userCred.user!.uid,
  'email': emailController.text.trim(),
  'phone': phoneController.text.trim(),
  'createdAt': FieldValue.serverTimestamp(),
});

// 🔹 Save basic user data locally for next steps
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', userCred.user!.uid);
    await prefs.setString('email', emailController.text.trim());
    await prefs.setString('phone', phoneController.text.trim());

    // Navigate to profile setup step 1
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Step1ProfileInfo()),
    );

    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "Unknown error";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 230,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF3F51B5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 60),
                const SizedBox(height: 10),
                Text("SafeHaven",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600)),
                Text("Your safety companion",
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        children: [
                          ToggleButtons(
                            isSelected: [false, true],
                            onPressed: (index) {
                              if (index == 0) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            fillColor: Colors.deepPurpleAccent,
                            selectedColor: Colors.white,
                            color: Colors.black54,
                            children: const [
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 8),
                                  child: Text("Login")),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 8),
                                  child: Text("Sign Up")),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomInputField(
                              controller: emailController,
                              hintText: 'your@email.com',
                              icon: Icons.email_outlined),
                          const SizedBox(height: 16),
                          CustomInputField(
                              controller: phoneController,
                              hintText: '+1234567890',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 16),
                          CustomInputField(
                              controller: passwordController,
                              hintText: 'Create a password',
                              icon: Icons.lock_outline,
                              obscureText: true),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signUpUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text("Create Account",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "By signing up, you agree to our Terms of Service and Privacy Policy",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "SafeHaven is committed to protecting women's safety\nAll data is encrypted and secure",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
