import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/format.dart';
import '../../core/sim_logic.dart';
import '../draw_utils.dart';
import 'sim_common.dart';

/// Depo seviye kontrolü ve pompa (iki sensörlü histerezis).
class PumpSim extends StatefulWidget {
  const PumpSim({super.key});

  @override
  State<PumpSim> createState() => _PumpSimState();
}

class _PumpSimState extends State<PumpSim> with SingleTickerProviderStateMixin {
  static const double _low = 25;
  static const double _high = 80;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _running = false;
  bool _demand = false;
  bool _pump = false;
  double _level = 20;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _pump = pumpNext(level: _level, pumpOn: false, lowPct: _low, highPct: _high);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0 || dt > 0.25) return;
    setState(() {
      _pump = pumpNext(level: _level, pumpOn: _pump, lowPct: _low, highPct: _high);
      _level = levelStep(level: _level, pumpOn: _pump, demandOpen: _demand, dt: dt);
      _pump = pumpNext(level: _level, pumpOn: _pump, lowPct: _low, highPct: _high);
    });
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _last = Duration.zero;
      _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = SimColors.of(context);
    final lowSeen = _level >= _low;
    final highSeen = _level >= _high;
    return SimScaffold(
      title: 'Depo seviye kontrolü ve pompa',
      aspect: 1.5,
      painter: _TankPainter(col: col, level: _level, pump: _pump, demand: _demand, low: _low, high: _high),
      controls: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _toggle,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'Duraklat' : 'Başlat'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  _level = 20;
                  _pump = pumpNext(level: _level, pumpOn: false, lowPct: _low, highPct: _high);
                }),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Sıfırla'),
              ),
            ),
          ],
        ),
        SwitchListTile(
          title: const Text('Kullanım vanası açık (depo boşalır)'),
          value: _demand,
          onChanged: (v) => setState(() => _demand = v),
        ),
        Text('Seviyeyi elle ayarla: %${fmtNum(_level, sig: 3)}'),
        Slider(
          min: 0,
          max: 100,
          value: _level,
          onChanged: (v) => setState(() {
            _level = v;
            _pump = pumpNext(level: _level, pumpOn: _pump, lowPct: _low, highPct: _high);
          }),
        ),
      ],
      info: [
        InfoCard(
          title: 'Giriş / çıkış durumu',
          child: Column(
            children: [
              StatusLine('I0.0  Alt seviye sensörü (suyu görüyor)', lowSeen ? '1' : '0', active: lowSeen),
              StatusLine('I0.1  Üst seviye sensörü (suyu görüyor)', highSeen ? '1' : '0', active: highSeen),
              StatusLine('Q0.0  Pompa kontaktörü', _pump ? '1' : '0', active: _pump),
            ],
          ),
        ),
        const InfoCard(
          title: 'Mantık',
          child: Text(
            'Seviye alt sensörün altına inince pompa çalışır ve (mühürleme mantığıyla) üst sensör suyu görene kadar çalışmaya devam eder. '
            'Aradaki bant (histerezis) pompanın sık sık aç-kapa yapmasını önler.\n\n'
            'Q0.0 = ( /I0.0  VEYA  Q0.0 )  VE  /I0.1\n\n'
            'Gerçek sistemlerde taşma ve kuru çalışmaya karşı ek emniyetler gerekir.',
          ),
        ),
      ],
    );
  }
}

class _TankPainter extends CustomPainter {
  final SimColors col;
  final double level;
  final bool pump;
  final bool demand;
  final double low;
  final double high;
  _TankPainter({required this.col, required this.level, required this.pump, required this.demand, required this.low, required this.high});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset o(double x, double y) => Offset(x, y);
    final tank = Rect.fromLTRB(0.36 * w, 0.1 * h, 0.64 * w, 0.88 * h);
    final waterTop = tank.bottom - tank.height * level / 100;
    canvas.drawRect(Rect.fromLTRB(tank.left, waterTop, tank.right, tank.bottom), fillPaint(const Color(0x883B82F6)));
    canvas.drawRect(tank, strokePaint(col.text, 3));

    // Sensörler
    for (final e in [(low, 'ALT'), (high, 'ÜST')]) {
      final y = tank.bottom - tank.height * e.$1 / 100;
      final seen = level >= e.$1;
      canvas.drawCircle(o(tank.right, y), 7, fillPaint(seen ? col.good : col.off));
      drawLabel(canvas, e.$2, o(tank.right + 24, y), color: col.text, size: 10, weight: FontWeight.w700);
      canvas.drawLine(o(tank.right - 8, y), o(tank.right, y), strokePaint(col.text, 1.5));
    }

    // Pompa ve boru (sol)
    final py = 0.78 * h;
    final pc = o(0.14 * w, py);
    canvas.drawCircle(pc, 0.07 * w, strokePaint(pump ? col.good : col.text, 3));
    if (pump) canvas.drawCircle(pc, 0.07 * w, fillPaint(const Color(0x442E9E4F)));
    drawLabel(canvas, 'M', pc, color: col.text, weight: FontWeight.w700);
    drawLabel(canvas, 'Pompa', o(pc.dx, py + 0.13 * h), color: col.text, size: 10);
    wire(canvas, o(pc.dx + 0.07 * w, py), o(tank.left, py), pump, col);
    canvas.drawLine(o(0.02 * w, py), o(pc.dx - 0.07 * w, py), strokePaint(col.off, 2.4));

    // Kullanım vanası (sağ alt)
    final vy = 0.8 * h;
    wire(canvas, o(tank.right, vy), o(0.84 * w, vy), demand, col);
    final vc = o(0.76 * w, vy);
    final tri = Path()
      ..moveTo(vc.dx - 10, vy - 10)
      ..lineTo(vc.dx + 10, vy + 10)
      ..lineTo(vc.dx + 10, vy - 10)
      ..lineTo(vc.dx - 10, vy + 10)
      ..close();
    canvas.drawPath(tri, strokePaint(demand ? col.on : col.bad, 2.4));
    drawLabel(canvas, demand ? 'Vana açık' : 'Vana kapalı', o(0.8 * w, vy + 0.12 * h), color: col.text, size: 10);

    drawLabel(canvas, '%${level.round()}', o(tank.center.dx, tank.top + 14), color: col.text, size: 13, weight: FontWeight.w700);
  }

  @override
  bool shouldRepaint(covariant _TankPainter old) => true;
}
