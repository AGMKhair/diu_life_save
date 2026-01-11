import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Blood Group')),
            TextField(decoration: const InputDecoration(labelText: 'Location')),
            TextField(decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Post'))
          ],
        ),
      ),
    );
  }
}
