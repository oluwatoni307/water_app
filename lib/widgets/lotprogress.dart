import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WaterLottieIndicator extends StatefulWidget {
  final num percentage; // from 0 to 100

  const WaterLottieIndicator({
    super.key,
    required this.percentage,
  });

  @override
  State<WaterLottieIndicator> createState() => _WaterLottieIndicatorState();
}

class _WaterLottieIndicatorState extends State<WaterLottieIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Set animation progress based on percentage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.value = (widget.percentage.clamp(0, 100)) / 100;
    });
  }

  @override
  void didUpdateWidget(covariant WaterLottieIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _controller.animateTo((widget.percentage.clamp(0, 100)) / 100);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Lottie.asset(
        'images/progress.json',
        controller: _controller,
        repeat: false,
        fit: BoxFit.contain,
      ),
    );
  }
}
