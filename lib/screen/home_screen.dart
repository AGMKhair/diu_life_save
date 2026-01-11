import 'package:diu_life_save/screen/create_post_screen.dart';
import 'package:diu_life_save/screen/profile_screen.dart';
import 'package:diu_life_save/screen/search_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
          title: const Text(
            'DIU LifeSave',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen())),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) => Card(
          child: ListTile(
            title: const Text('O+ Blood Needed'),
            subtitle: const Text('DIU Dhaka'),
            trailing: const Icon(Icons.bloodtype, color: Colors.red),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
          if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),
    );
  }
}
