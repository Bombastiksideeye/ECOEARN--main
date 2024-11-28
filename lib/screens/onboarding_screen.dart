import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../widgets/eco_earn_logo.dart';

class CustomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondEndPoint = Offset(size.width, size.height - 80);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView to display onboarding pages
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2; // Update to check for the last page
              });
            },
            children: [
              // First Page (Logo)
              Container(
                color: Colors.white,
                child: const Center(
                  child: EcoEarnLogo(height: 40),
                ),
              ),
              // Second Page (Recycle)
              OnboardingPage(
                image: 'assets/images/Group 36700.png',
                title: 'Recycle',
                description:
                    'New memories will be made. A much better option than being discarded and forgotten by becoming part of the adventure - recycle now!',
                backgroundColor: const Color(0xFF2E7D32), // Dark green color
                controller: _controller,
                isLastPage: isLastPage,
              ),
              // Third Page (Get Rewards)
              OnboardingPage(
                image: 'assets/images/rewards_illustration.png',
                title: 'Get Rewards',
                description:
                    'You can participate and earn points. You will be rewarded with prizes from us when you complete a challenge recycle.',
                backgroundColor: const Color(0xFF2E7D32),
                showButton: true,
                controller: _controller,
                isLastPage: isLastPage,
                onButtonPressed: () {
                  // Navigate to sign up screen
                  Navigator.pushReplacementNamed(context, '/signin');
                },
              ),
            ],
          ),

          // SmoothPageIndicator displayed here
          Positioned(
            bottom: 120, // Position the indicator at the bottom of the screen
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150),
              child: Container(
                height: 15,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 241, 241),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: 3, // Set the count to 3 to match the number of pages
                    effect: const WormEffect(
                      spacing: 7,
                      dotHeight: 7,
                      dotWidth: 7,
                      dotColor: Colors.black26,
                      activeDotColor: Color(0xFF2E7D32),
                    ),
                    onDotClicked: (index) => _controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final Color backgroundColor;
  final bool showButton;
  final VoidCallback? onButtonPressed;
  final PageController controller;
  final bool isLastPage;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.controller,
    required this.isLastPage,
    this.showButton = false,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Apply shadow outside the ClipPath and curve the container
            Stack(
              children: [
                ClipPath(
                  clipper: CustomCurveClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ),
                ),
                ClipPath(
                  clipper: CustomCurveClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF34A853),
                          Color(0xFF144221),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: Image.asset(
                          image,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),

            // Add SizedBox to introduce a 40px gap between the text and the indicator
            const SizedBox(height: 40),

            // Button section displayed if showButton is true
            if (showButton) ...[
              const SizedBox(height: 40),
              GestureDetector(
                onTap: onButtonPressed,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF34A853),
                        Color(0xFF144221),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
