import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiveClockCard extends StatelessWidget {
  final String workingTime;
  final double progress;

  final TimeOfDay? shiftStart;
  final TimeOfDay? shiftEnd;

  const LiveClockCard({
    super.key,
    required this.workingTime,
    required this.progress,
    required this.shiftStart,
    required this.shiftEnd,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Colors.white;
    final primaryColor = const Color(0xFF6366F1); // same indigo feel

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ───── SHIFT LABELS ─────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ShiftLabel(
                title: "Shift Start",
                time: shiftStart?.format(context) ?? "--:--",
              ),
              _ShiftLabel(
                title: "Shift End",
                time: shiftEnd?.format(context) ?? "--:--",
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ───── ARC + TIME ─────
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final arcWidth = width * 0.75;
              final arcHeight = arcWidth / 2;

              final timeFontSize = arcWidth * 0.14;
              final labelFontSize = arcWidth * 0.07;

              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: arcWidth,
                    height: arcHeight,
                    child: CustomPaint(
                      painter: _ModernArcPainter(progress, primaryColor),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    child: Column(
                      children: [
                        // ⏱ Working time
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            workingTime,
                            style: TextStyle(
                              fontSize: timeFontSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // 📄 Subtitle
                        Text(
                          workingTime == "00:00"
                              ? "Not punched in"
                              : "Working hours",
                          style: TextStyle(
                            fontSize: labelFontSize,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────

class _ShiftLabel extends StatelessWidget {
  final String title;
  final String time;

  const _ShiftLabel({required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: title == "Shift Start"
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────

class _ModernArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ModernArcPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);

    // Base arc
    final basePaint = Paint()
      ..color = Colors.grey.withOpacity(.12)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, basePaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [color, color.withOpacity(.6)],
        ).createShader(rect);

      canvas.drawArc(
        rect,
        math.pi,
        math.pi * progress.clamp(0, 1),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ModernArcPainter old) =>
      old.progress != progress;
}
