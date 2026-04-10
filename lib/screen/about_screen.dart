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
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo Section
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.jpeg',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Campus Blood Donorly',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
            const Text(
              'A Humanitarian Bridge',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Description
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'Campus Blood Donorly is not just an app; it is a humanitarian bridge. Operated with the dedicated support of the Law Department of Dhaka International University (DIU), this volunteer-driven platform ensures quick communication between blood donors and recipients in critical moments. Our goal is to build a blood-shortage-free campus and society through the proper use of technology.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Goals Section
                  const Text(
                    '🤝 Our Goals and Objectives',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGoalItem(
                    Icons.flash_on_rounded,
                    'Fast Service',
                    'Finding blood donors within just a few clicks during emergencies.',
                  ),
                  _buildGoalItem(
                    Icons.connect_without_contact_rounded,
                    'Easy Connection',
                    'A simple way to directly communicate with blood donors.',
                  ),
                  _buildGoalItem(
                    Icons.favorite_rounded,
                    'Awareness',
                    'Encouraging and inspiring the younger generation to donate blood.',
                  ),

                  const SizedBox(height: 40),

                  // Partners/Sponsors
                  const Text(
                    'Supported & Sponsored By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPartnerCard(
                          'assets/images/law_club.jpeg',
                          'Law Club, DIU',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPartnerCard(
                          bg: Color(0xFFDFD9D9),
                          'assets/images/spont_logo.png', // Using app logo as placeholder for Spont IT
                          'SponT IT',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Developer Info
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Created with ❤️ by',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _launchUrl(portfolioLink),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                developerName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                              SizedBox(width: 10,),
                              GestureDetector(
                                onTap: () async {
                                  final url = Uri.parse(portfolioLink);
                                  if (await canLaunchUrl(url)) {
                                    launchUrl(url);
                                  }
                                },
                                child: const Icon(
                                  Icons.link,
                                  size: 24,
                                  color: Colors.blue,
                                ),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(String imagePath, String name, {Color bg = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            height: 50,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
