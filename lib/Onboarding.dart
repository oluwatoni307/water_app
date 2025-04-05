import 'package:flutter/material.dart';
// import 'package:water/login.dart';
import 'package:water/widgets/onboarding_widget.dart';

class OnBoardingPageView extends StatefulWidget {
  const OnBoardingPageView({Key? key}) : super(key: key);

  @override
  _OnBoardingPageViewState createState() => _OnBoardingPageViewState();
}

class _OnBoardingPageViewState extends State<OnBoardingPageView> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  // Data for each onboarding screen.
  final List<Map<String, String>> onboardingScreens = [
    {
      "image": "images/1.png",
      "title": "Track your daily water intake with Us.",
      "description": "Achieve your hydration goals with a simple tap!",
      "buttonText": "Next"
    },
    {
      "image": "images/2.png",
      "title": "Stay Hydrated!",
      "description": "Never forget to drink water.",
      "buttonText": "Next"
    },
    {
      "image": "images/gpt.png",
      "title": "",
      "description": "It is recommended to take a liter of water a day.",
      "buttonText": "Next"
    },
    {
      "image": "images/3.png",
      "title": "Ready to Start?",
      "description": "Let's get you set up.",
      "buttonText": "Get Started"
    },
  ];

  // Update the current page index
  void _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  // Button action: navigate to next page or finish onboarding
  void _onButtonPressed() {
    if (currentPage < onboardingScreens.length - 1) {
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Final action: Navigate to the main app screen or complete onboarding
      // For example:

      Navigator.pushNamed(context, '/'); // Navigate to GoalPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: onboardingScreens.length,
        itemBuilder: (context, index) {
          final screen = onboardingScreens[index];
          return OnBoardingScreen(
            imagePath: screen["image"]!,
            title: screen["title"]!,
            description: screen["description"]!,
            buttonText: screen["buttonText"]!,
            currentPage: currentPage, // Pass currentPage
            onButtonPressed: _onButtonPressed,
          );
        },
      ),
    );
  }
}
