import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_input_field.dart';

class LoginScreen extends StatelessWidget {
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
                Icon(Icons.shield_outlined, color: Colors.white, size: 60),
                SizedBox(height: 10),
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
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                            isSelected: [true, false],
                            onPressed: (index) {
                              if (index == 1) {
                                Navigator.pushReplacementNamed(
                                    context, '/signup');
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
                          SizedBox(height: 24),
                          CustomInputField(
                              hintText: 'your@email.com or +1234567890',
                              icon: Icons.email_outlined),
                          SizedBox(height: 16),
                          CustomInputField(
                              hintText: 'Enter your password',
                              icon: Icons.lock_outline,
                              obscureText: true),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text("Forgot password?",
                                  style: TextStyle(color: Colors.purple)),
                            ),
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Login",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
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
