import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'draw_utils.dart';

/// Temsili devre sembolleri (IEC mantığına yakın, standart onaylı çizim değildir).
class SymbolView extends StatelessWidget {
  final String kind;
  final double width;
  const SymbolView({super.key, required this.kind, this.width = 120});

  @override
  Widget build(BuildContext context) {
    final col = SimColors.of(context);
    return SizedBox(
      width: width,
      height: width / 2,
      child: CustomPaint(painter: _SymbolPainter(kind, col)),
    );
  }
}

class _SymbolPainter extends CustomPainter {
  final String kind;
  final SimColors col;
  _SymbolPainter(this.kind, this.col);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120, size.height / 60);
    final p = strokePaint(col.text, 2.4);
    Offset o(double x, double y) => Offset(x, y);
    void line(double x1, double y1, double x2, double y2) => canvas.drawLine(o(x1, y1), o(x2, y2), p);
    void leads(double a, double b) {
      line(0, 30, a, 30);
      line(b, 30, 120, 30);
    }

    switch (kind) {
      case 'resistor':
        leads(35, 85);
        canvas.drawRect(Rect.fromLTRB(35, 20, 85, 40), p);
      case 'capacitor':
        leads(52, 68);
        line(52, 10, 52, 50);
        line(68, 10, 68, 50);
      case 'inductor':
        leads(20, 100);
        for (var i = 0; i < 4; i++) {
          canvas.drawArc(Rect.fromLTWH(20.0 + 20 * i, 18, 20, 24), math.pi, math.pi, false, p);
        }
      case 'diode':
      case 'led':
        leads(45, 75);
        final tri = Path()
          ..moveTo(45, 14)
          ..lineTo(45, 46)
          ..lineTo(75, 30)
          ..close();
        canvas.drawPath(tri, p);
        line(75, 14, 75, 46);
        if (kind == 'led') {
          line(58, 12, 72, 2);
          line(68, 16, 82, 6);
        }
      case 'battery':
        leads(40, 80);
        line(40, 8, 40, 52);
        line(52, 18, 52, 42);
        line(68, 8, 68, 52);
        line(80, 18, 80, 42);
        drawLabel(canvas, '+', o(32, 10), size: 12, color: col.text);
      case 'lamp':
        leads(42, 78);
        canvas.drawCircle(o(60, 30), 18, p);
        line(47, 17, 73, 43);
        line(47, 43, 73, 17);
      case 'coil':
        leads(40, 80);
        canvas.drawRect(Rect.fromLTRB(40, 14, 80, 46), p);
        drawLabel(canvas, 'A1  A2', o(60, 30), size: 10, color: col.text);
      case 'fuse':
        line(0, 30, 120, 30);
        canvas.drawRect(Rect.fromLTRB(35, 20, 85, 40), p);
      case 'contact_no':
        leads(45, 75);
        canvas.drawCircle(o(45, 30), 3, fillPaint(col.text));
        canvas.drawCircle(o(75, 30), 3, fillPaint(col.text));
        line(45, 30, 73, 10);
      case 'thermal':
        leads(35, 85);
        canvas.drawRect(Rect.fromLTRB(35, 14, 85, 46), p);
        drawLabel(canvas, 'I >', o(60, 30), size: 13, color: col.text, weight: FontWeight.w700);
      case 'estop':
        leads(42, 78);
        canvas.drawCircle(o(60, 30), 18, fillPaint(const Color(0xFFD32F2F)));
        canvas.drawCircle(o(60, 30), 18, p);
        drawLabel(canvas, 'NC', o(60, 30), size: 11, color: Colors.white, weight: FontWeight.w700);
      case 'motor':
        leads(40, 80);
        canvas.drawCircle(o(60, 30), 20, p);
        drawLabel(canvas, 'M\n3~', o(60, 30), size: 12, color: col.text, weight: FontWeight.w700);
      default:
        line(0, 30, 120, 30);
    }
  }

  @override
  bool shouldRepaint(covariant _SymbolPainter old) => old.kind != kind || old.col.text != col.text;
}
