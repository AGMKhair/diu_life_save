import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Donor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Blood Group')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (_, i) => Card(
                  child: ListTile(
                    title: const Text('Available Donor'),
                    subtitle: const Text('O+ | CSE'),
                    trailing: IconButton(icon: const Icon(Icons.call), onPressed: () {}),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
