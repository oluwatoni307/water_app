import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoDialog extends StatefulWidget {
  final VoidCallback? onFinish;

  const InfoDialog({
    super.key,
    this.onFinish,
  });

  @override
  _InfoDialogState createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  int _currentIndex = 0;

  // Updated list with title and message
  final List<Map<String, String>> _onboardingSteps = [
    {
      'title': 'Welcome to BlueDrop',
      'message':
          'This app helps you stay hydrated by tracking your daily water intake.',
    },
    {
      'title': 'Set Your Goals',
      'message':
          'Set a daily water goal in the Goals section to personalize your hydration plan.',
    },
    {
      'title': 'Log Water Easily',
      'message':
          'Log your water intake easily by tapping "Log your water" on the home screen.',
    },
    {
      'title': 'Track Your Progress',
      'message': 'Check your progress and weekly stats to stay motivated!',
    },
  ];

  void _next() {
    if (_currentIndex < _onboardingSteps.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _back() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _finish() {
    widget.onFinish?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentIndex == _onboardingSteps.length - 1;
    final step = _onboardingSteps[_currentIndex];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        step['title']!,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Text(
          step['message']!,
          key: ValueKey(_currentIndex),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      actions: [
        if (_currentIndex > 0)
          TextButton(
            onPressed: _back,
            child: Text(
              'Back',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextButton(
          onPressed: _finish,
          child: Text(
            'Skip',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (!isLast)
          TextButton(
            onPressed: _next,
            child: Text(
              'Next',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (isLast)
          TextButton(
            onPressed: _finish,
            child: Text(
              'Finish',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
