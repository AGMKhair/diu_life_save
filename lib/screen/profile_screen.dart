import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: const [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            SizedBox(height: 16),
            Text('AGM Khair Sabbir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('O+ | CSE | DIU'),
          ],
        ),
      ),
    );
  }
}