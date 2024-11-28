import 'package:ecoearn/screens/home/home_screen.dart';
import 'package:ecoearn/screens/learn/learn_screen1.dart';
import 'package:ecoearn/screens/learn/learn_screen2.dart';
import 'package:ecoearn/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Makes the body scrollable
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'Waste Less, ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Live More!',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Good to know section
                const Text(
                  'Good to know',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // Horizontal cards
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildInfoCard(
      title: 'What plastics\ncan be recycled?',
      iconPath: 'assets/images/image 35.png',
      ontap: () {
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LearnScreen1(), // Replace with appropriate screen
          ),
        );
      },
    ),
    _buildInfoCard(
      title: 'Ways to\nreduce waste',
      iconPath: 'assets/images/image 37 (1).png',
      ontap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LearnScreen2(),
          ),
        );
      },
    ),
  ],
),

                const SizedBox(height: 30),

                // Topic for you section
                const Text(
                  'Topic for you',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // List of topics
                Column(
                  children: [
                    _buildTopicCard(
                      imagePath: 'assets/images/image.png',
                      title: 'Waste to artwork',
                      description:
                          'Artists use recycled or reused objects to make attractive pieces of contemporary art.',
                    ),
                    const SizedBox(height: 16),
                    _buildTopicCard(
                      imagePath: 'assets/images/image (1).png',
                      title: 'Become a volunteer',
                      description:
                          'Join efforts to recycle and reduce waste through volunteering activities in your community.',
                    ),
                    const SizedBox(height: 16),
                    _buildTopicCard(
                      imagePath: 'assets/images/image (2).png',
                      title: 'Community Recycling',
                      description:
                          'Learn how communities work together to promote recycling and sustainability.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Sets 'Learn' as active tab
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline)),
            label: 'Learn',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // Info card widget
  Widget _buildInfoCard({
    required String iconPath,
    required String title,
    required VoidCallback ontap, // Callback function
  }) {
    return GestureDetector(
      onTap: ontap, // Triggers the provided callback when tapped
      child: Container(
        width: 150,
        height: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  iconPath,
                  height: 70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Topic card widget
  Widget _buildTopicCard({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.3),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
