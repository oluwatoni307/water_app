import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingScreen extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;
  final int currentPage; // Add currentPage for dynamic indicator

  final VoidCallback onButtonPressed; // Callback for button action

  const OnBoardingScreen({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.currentPage, // Pass currentPage
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 70),
            // Main content section: image, title, description
            Column(
              children: [
                Image.asset(
                  widget.imagePath,
                  width: 300,
                  height: 300,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            // Dynamic Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4, // Replace 3 with actual length of onboarding screens
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: widget.currentPage == index ? 35.0 : 20.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: widget.currentPage == index
                        ? const Color(0xFF5DCCFC)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
            Spacer(),
            // Action Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  print("Button pressed on page: ${widget.buttonText}");
                  // Correctly invoke the callback function.
                  widget.onButtonPressed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5DCCFC),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 110, vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget.buttonText,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
