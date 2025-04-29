import 'dart:math' as math;
import 'package:flutter/material.dart';

class ElegantGlassWidget extends StatefulWidget {
  final double level; // 0.0 to 1.0
  final Color waterColor;

  const ElegantGlassWidget({
    Key? key,
    required this.level,
    this.waterColor = Colors.lightBlueAccent,
  }) : super(key: key);

  @override
  State<ElegantGlassWidget> createState() => _ElegantGlassWidgetState();
}

class _ElegantGlassWidgetState extends State<ElegantGlassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ElegantGlassPainter(
            level: widget.level,
            wavePhase: _waveController.value,
            waterColor: widget.waterColor,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ElegantGlassPainter extends CustomPainter {
  final double level; // 0.0 - 1.0
  final double wavePhase; // 0.0 - 1.0
  final Color waterColor;

  _ElegantGlassPainter({
    required this.level,
    required this.wavePhase,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double topWidth = size.width * 0.9;
    final double bottomWidth = size.width * 0.6;
    final double height = size.height;

    final double topX = (size.width - topWidth) / 2;
    final double bottomX = (size.width - bottomWidth) / 2;

    final Path glassPath = Path()
      ..moveTo(topX, 0)
      ..quadraticBezierTo(topX, height * 0.5, bottomX, height)
      ..lineTo(bottomX + bottomWidth, height)
      ..quadraticBezierTo(topX + topWidth, height * 0.5, topX + topWidth, 0)
      ..close();

    // Glass gradient
    final Paint glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(glassPath, glassPaint);

    // Glass outline
    final Paint outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.7),
          Colors.grey.withOpacity(0.5),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(glassPath, outlinePaint);

    // Clip water to glass
    canvas.save();
    canvas.clipPath(glassPath);

    final double fillHeight = height * level;
    final double waterTop = height - fillHeight;

    final Path wavePath = Path();
    final int waveCount = 2;
    final double amplitude = size.height * 0.025;
    final double wavelength = size.width / waveCount;

    wavePath.moveTo(0, waterTop);

    for (double x = 0; x <= size.width; x++) {
      double y = waterTop +
          math.sin((x / wavelength + wavePhase * 2 * math.pi)) * amplitude;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    final Paint waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          waterColor.withOpacity(0.9),
          waterColor.withOpacity(0.6),
        ],
      ).createShader(Rect.fromLTWH(0, waterTop, size.width, fillHeight));

    canvas.drawPath(wavePath, waterPaint);

    canvas.restore();

    // Optional shimmer
    final Paint shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width * 0.3, size.height));

    final Path shimmer = Path()
      ..moveTo(topX + topWidth * 0.3, 0)
      ..lineTo(topX + topWidth * 0.35, 0)
      ..lineTo(bottomX + bottomWidth * 0.45, height)
      ..lineTo(bottomX + bottomWidth * 0.4, height)
      ..close();

    canvas.drawPath(shimmer, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
