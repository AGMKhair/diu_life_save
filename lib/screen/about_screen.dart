import 'package:flutter/material.dart';
import 'package:diu_life_save/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final String developerName = 'AGM Khair Sabbir';
  final String portfolioLink = 'https://agmkhair.com';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo with shadow
            Image.asset(
              'assets/images/diu_logo.png',
              height: 100,
            ),

            const SizedBox(height: 16),

            // App Name
            const Text(
              'Campus Blood Donorly',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // About Us Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                  textAlign: TextAlign.justify,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text:
                        'Campus Blood Donorly is a voluntary blood donation platform operated with the support of the ',
                      ),
                      TextSpan(
                        text: 'Department of Law, Dhaka International University (DIU). ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                        'The app connects blood donors with patients quickly during emergencies.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Team Members Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Team Members',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text('• Project Coordinator', style: TextStyle(fontSize: 16)),
                    Text('• App Development Team', style: TextStyle(fontSize: 16)),
                    Text('• Volunteer & Donor Management Team', style: TextStyle(fontSize: 16)),
                    Text('• Awareness & Communication Team', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Slogan
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Donate Blood. Save Life.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),

            // Developer Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Developed by ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(portfolioLink);
                    if (await canLaunchUrl(url)) {
                      launchUrl(url);
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        developerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.link,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
