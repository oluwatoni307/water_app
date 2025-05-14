import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersuadeDialog extends StatefulWidget {
  final VoidCallback? onClose;

  const PersuadeDialog({
    super.key,
    this.onClose,
  });

  @override
  _PersuadeDialogState createState() => _PersuadeDialogState();
}

class _PersuadeDialogState extends State<PersuadeDialog> {
  // List of onboarding steps
  final List<Map<String, String>> _onboardingSteps = [
    {
      'title': 'Welcome to WaterTrack',
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

  late Map<String, String> _randomStep;

  @override
  void initState() {
    super.initState();
    // Select a random step on initialization
    _randomStep = _onboardingSteps[Random().nextInt(_onboardingSteps.length)];
  }

  void _close() {
    widget.onClose?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _randomStep['title']!,
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
          _randomStep['message']!,
          key: ValueKey(_randomStep['title']),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _close,
          child: Text(
            'Close',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
