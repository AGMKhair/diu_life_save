import 'package:diu_life_save/screen/create_post_screen.dart';
import 'package:diu_life_save/screen/profile_screen.dart';
import 'package:diu_life_save/screen/search_screen.dart';
import 'package:diu_life_save/screen/view_request_screen.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'DIU LifeSave',
      //     style: TextStyle(fontWeight: FontWeight.w600),
      //   ),
      //   centerTitle: true,
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🩸 ICON / LOGO
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bloodtype,
                  size: 60,
                  color: AppColors.primaryRed,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Donate Blood\nSave Life',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔴 MENU BUTTONS
              _menuButton(
                context,
                title: 'View Blood Requests',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ViewRequestScreen()),
                  );
                },
              ),

              _menuButton(
                context,
                title: 'Add Blood Request',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                  );
                },
              ),

              _menuButton(
                context,
                title: 'Available Blood Group',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),

              _menuButton(
                context,
                title: 'My Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),

              _menuButton(
                context,
                title: 'About',
                onTap: () {
                  _showAbout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔴 Reusable Button
  Widget _menuButton(
      BuildContext context, {
        required String title,
        required VoidCallback onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: onTap,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// ℹ️ ABOUT DIALOG
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About DIU LifeSave'),
        content: const Text(
          'DIU LifeSave is a blood donation platform\n'
              'created to help people find blood donors easily.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }
}
