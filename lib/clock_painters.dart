import 'dart:math';
import 'package:flutter/material.dart';

class ClockFacePainter extends CustomPainter {
  final BuildContext context;

  ClockFacePainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final paint = Paint()
      ..color = isDarkMode 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
          : Theme.of(context).colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw minute markers
    for (int i = 0; i < 60; i++) {
      final angle = i * (2 * pi / 60);
      final markerLength = i % 5 == 0 ? 15.0 : 8.0;
      final outerPoint = center + Offset(
        (radius - 10) * cos(angle),
        (radius - 10) * sin(angle),
      );
      final innerPoint = center + Offset(
        (radius - 10 - markerLength) * cos(angle),
        (radius - 10 - markerLength) * sin(angle),
      );
      canvas.drawLine(innerPoint, outerPoint, paint);
    }

    // Draw numbers
    final textPaint = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final textColor = isDarkMode 
        ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
        : Theme.of(context).colorScheme.primary;

    for (int i = 5; i <= 60; i += 5) {
      final angle = i * (2 * pi / 60) - pi / 2;
      final textRadius = radius - 35;
      final position = center + Offset(
        textRadius * cos(angle),
        textRadius * sin(angle),
      );

      textPaint.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPaint.layout();
      textPaint.paint(
        canvas,
        position + Offset(-textPaint.width / 2, -textPaint.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ClockHandsPainter extends CustomPainter {
  final BuildContext context;
  final int remainingSeconds;

  ClockHandsPainter(this.context, this.remainingSeconds);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate angles
    final totalMinutes = remainingSeconds / 60;
    final minuteAngle = (totalMinutes * (2 * pi / 60)) - pi / 2;
    final secondAngle = ((remainingSeconds % 60) * (2 * pi / 60)) - pi / 2;

    // Draw minute hand
    final minuteHandPaint = Paint()
      ..color = isDarkMode
          ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
          : Theme.of(context).colorScheme.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final minuteHand = center + Offset(
      (radius - 40) * cos(minuteAngle),
      (radius - 40) * sin(minuteAngle),
    );
    canvas.drawLine(center, minuteHand, minuteHandPaint);

    // Draw second hand
    final secondHandPaint = Paint()
      ..color = isDarkMode
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.9)
          : Theme.of(context).colorScheme.secondary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final secondHand = center + Offset(
      (radius - 30) * cos(secondAngle),
      (radius - 30) * sin(secondAngle),
    );
    canvas.drawLine(center, secondHand, secondHandPaint);

    // Draw center dot
    final centerDotPaint = Paint()
      ..color = isDarkMode
          ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
          : Theme.of(context).colorScheme.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerDotPaint);
  }

  @override
  bool shouldRepaint(ClockHandsPainter oldDelegate) =>
      oldDelegate.remainingSeconds != remainingSeconds;
}
