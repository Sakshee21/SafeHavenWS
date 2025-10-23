import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You can later connect this to backend or Firebase
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            SizedBox(height: 16),
            Text('Name: Jane Doe', style: TextStyle(fontSize: 18)),
            Text('Role: Volunteer', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Email: jane@example.com'),
            SizedBox(height: 16),
            Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(currentRoute: '/profile', role: 'volunteer'),
    );
  }
}
