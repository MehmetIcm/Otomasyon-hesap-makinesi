import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Simülasyon ve sembol çizimleri için tema uyumlu renkler.
class SimColors {
  final Color off;
  final Color on;
  final Color text;
  final Color good;
  final Color bad;
  const SimColors({
    required this.off,
    required this.on,
    required this.text,
    required this.good,
    required this.bad,
  });

  factory SimColors.of(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SimColors(
      off: cs.outline,
      on: const Color(0xFFFFA000),
      text: cs.onSurface,
      good: const Color(0xFF2E9E4F),
      bad: const Color(0xFFE5484D),
    );
  }
}

Paint strokePaint(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint fillPaint(Color c) => Paint()
  ..color = c
  ..style = PaintingStyle.fill;

void drawLabel(Canvas canvas, String text, Offset center,
    {double size = 11, Color color = Colors.black, FontWeight weight = FontWeight.w500}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color, fontWeight: weight, height: 1.15)),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  )..layout();
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
}

/// Enerjili hatlar kalın ve renkli, enerjisiz hatlar ince ve gri çizilir.
void wire(Canvas c, Offset a, Offset b, bool on, SimColors col) {
  c.drawLine(a, b, strokePaint(on ? col.on : col.off, on ? 3.6 : 2.4));
}

/// Anahtar / kontak: [closed] true ise iletim yolu kapalıdır. [nc] normalde kapalı işareti ekler.
void drawContact(Canvas c, Offset center, double half,
    {required bool closed, required bool nc, required SimColors col, bool on = false}) {
  final l = Offset(center.dx - half, center.dy);
  final r = Offset(center.dx + half, center.dy);
  final p = strokePaint(on ? col.on : col.text, 2.6);
  c.drawCircle(l, 2.8, fillPaint(col.text));
  c.drawCircle(r, 2.8, fillPaint(col.text));
  if (closed) {
    c.drawLine(l, r, p);
  } else {
    c.drawLine(l, Offset(r.dx - 2, center.dy - half * 0.8), p);
  }
  if (nc) {
    c.drawLine(Offset(r.dx - 5, center.dy - half * 0.55), Offset(r.dx - 5, center.dy), strokePaint(col.text, 1.8));
  }
}

void drawLamp(Canvas c, Offset center, double r, double brightness, SimColors col) {
  if (brightness > 0) {
    c.drawCircle(center, r * 1.35, fillPaint(Color.fromRGBO(255, 193, 7, 0.35 * brightness)));
    c.drawCircle(center, r, fillPaint(Color.fromRGBO(255, 214, 64, 0.35 + 0.65 * brightness)));
  }
  c.drawCircle(center, r, strokePaint(col.text, 2.2));
  final d = r * 0.7071;
  c.drawLine(center + Offset(-d, -d), center + Offset(d, d), strokePaint(col.text, 1.8));
  c.drawLine(center + Offset(-d, d), center + Offset(d, -d), strokePaint(col.text, 1.8));
}

void drawCoilBox(Canvas c, Offset center, double w, double h, bool energized, String label, SimColors col) {
  final rect = Rect.fromCenter(center: center, width: w, height: h);
  if (energized) c.drawRect(rect, fillPaint(Color.fromRGBO(46, 158, 79, 0.35)));
  c.drawRect(rect, strokePaint(energized ? col.good : col.text, 2.4));
  drawLabel(c, label, center, color: col.text, weight: FontWeight.w700);
}

void drawMotorSymbol(Canvas c, Offset center, double r, bool running, double angle, SimColors col) {
  c.drawCircle(center, r, strokePaint(running ? col.good : col.text, 2.6));
  drawLabel(c, 'M\n3~', center, size: r * 0.6, color: col.text, weight: FontWeight.w700);
  if (running) {
    final tip = center + Offset(math.cos(angle), math.sin(angle)) * (r * 0.9);
    c.drawCircle(tip, 3, fillPaint(col.good));
  }
}
