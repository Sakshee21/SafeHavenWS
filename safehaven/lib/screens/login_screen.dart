import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Normalizes role strings to lowercase tokens for easier checks.
  /// Accepts variations such as "User / Victim", "user", "Victim", etc.
  bool _containsUserRole(List<dynamic> roles) {
    for (var r in roles) {
      final s = r.toString().toLowerCase();
      if (s.contains('user') || s.contains('victim')) return true;
    }
    return false;
  }

  bool _containsVolunteerRole(List<dynamic> roles) {
    for (var r in roles) {
      final s = r.toString().toLowerCase();
      if (s.contains('volunteer')) return true;
    }
    return false;
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1) Sign in with Firebase Auth
      final userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = userCred.user;
      if (user == null) throw Exception('Login failed');

      // 2) Fetch Firestore user doc
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // No Firestore profile — redirect to profile setup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please complete your profile setup.")),
        );
        // adjust route to your step1 route name if different
        Navigator.pushReplacementNamed(context, '/profile-setup-step1');
        return;
      }

      // 3) Read roles array (robust against missing or different shapes)
      final data = doc.data()!;
      final rolesRaw = data['roles'];

      if (rolesRaw == null) {
        // roles field missing → require completing profile
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No roles assigned. Please complete setup.")),
        );
        Navigator.pushReplacementNamed(context, '/profile-setup-step1');
        return;
      }

      // rolesRaw might be a List<dynamic> or single string
      List<dynamic> rolesList;
      if (rolesRaw is List) {
        rolesList = rolesRaw;
      } else {
        // try to coerce a single string into a list
        rolesList = [rolesRaw];
      }

      // 4) Determine which dashboard to open
      final hasUser = _containsUserRole(rolesList);
      final hasVolunteer = _containsVolunteerRole(rolesList);

      if (hasUser && hasVolunteer) {
        Navigator.pushReplacementNamed(context, '/combined_home');
      } else if (hasUser) {
        Navigator.pushReplacementNamed(context, '/user_home');
      } else if (hasVolunteer) {
        Navigator.pushReplacementNamed(context, '/volunteer_home');
      } else {
        // Unknown roles — fallback to profile setup or a neutral home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No valid role found. Please update profile.")),
        );
        Navigator.pushReplacementNamed(context, '/profile-setup-step1');
      }

      // friendly snackbar (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, ${user.email ?? ''}")),
      );
    } on FirebaseAuthException catch (e) {
      var message = 'Login failed';
      if (e.code == 'user-not-found') message = 'No user found for this email.';
      if (e.code == 'wrong-password') message = 'Incorrect password.';
      if (e.code == 'invalid-email') message = 'Invalid email format.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
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
                const Icon(Icons.shield_outlined, color: Colors.white, size: 60),
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

          // Login Card
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
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        children: [
                          ToggleButtons(
                            isSelected: const [true, false],
                            onPressed: (index) {
                              if (index == 1) {
                                Navigator.pushReplacementNamed(context, '/signup');
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            fillColor: Colors.deepPurpleAccent,
                            selectedColor: Colors.white,
                            color: Colors.black54,
                            children: const [
                              Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                  child: Text("Login")),
                              Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                  child: Text("Sign Up")),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Email / Phone
                          CustomInputField(
                            controller: _emailController,
                            hintText: 'your@email.com',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          CustomInputField(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: implement password reset
                              },
                              child: const Text("Forgot password?",
                                  style: TextStyle(color: Colors.purple)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Login",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
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
