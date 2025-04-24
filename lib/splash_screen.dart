import 'package:flutter/material.dart';
import 'package:water/Onboarding.dart';

import 'package:wave/wave.dart';
import 'package:wave/config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Add a delay before navigating to the next screen
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        // Check if widget is still mounted
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnBoardingPageView()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Dispose any animations or resources here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.water_drop,
                        size: 160,
                        color: Colors.white,
                      ),
                      Positioned(
                        right: -30,
                        top: -50,
                        child: const Icon(
                          Icons.water_drop,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Water Tracker',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Stay hydrated and\ntrack your daily water intake',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                      width: 100,
                      height: 50,
                      child: DotAnimation(
                        numberOfDots: 3,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: WaveWidget(
                config: CustomConfig(
                  gradients: [
                    [Colors.blue, Colors.blue.shade200],
                    [Colors.blueAccent, Colors.blue.shade100],
                  ],
                  durations: [4000, 3200],
                  heightPercentages: [0.20, 0.25],
                  blur: MaskFilter.blur(BlurStyle.solid, 10),
                ),
                waveAmplitude: 25,
                size: Size(
                    double.infinity, MediaQuery.of(context).size.height * 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... [Rest of the original code remains the same]

class BouncingDots extends StatefulWidget {
  final int numberOfDots;
  final Color dotColor;

  const BouncingDots({
    super.key,
    this.numberOfDots = 3,
    this.dotColor = Colors.white,
  });

  @override
  _BouncingDotsState createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Adjust speed here
      vsync: this,
    )..repeat(reverse: true); // Repeat the animation in reverse

    // Create staggered animations for each dot
    _animations = List.generate(widget.numberOfDots, (index) {
      return Tween<double>(begin: -30.0, end: 30.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.0 + (index / widget.numberOfDots) * 0.5, // Stagger start times
            1.0 - (index / widget.numberOfDots) * 0.5, // Stagger end times
            curve: Curves.easeInOut, // Smooth easing
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100, // Container width
        height: 20, // Container height (to fit the dots vertically)
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.numberOfDots, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                // Calculate horizontal position
                double x = _animations[index].value;

                return Transform.translate(
                  offset: Offset(x, 0),
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 16, // Dot size
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Circular dots
                  color: widget.dotColor,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller
    super.dispose();
  }
}

// Helper class for creating dot animations
class DotAnimation extends StatelessWidget {
  final Color color;
  final int numberOfDots;

  const DotAnimation({
    super.key,
    this.color = Colors.white,
    this.numberOfDots = 3,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingDots(
      numberOfDots: numberOfDots,
      dotColor: color,
    );
  }
}
