import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/format.dart';
import '../../core/sim_logic.dart';
import '../draw_utils.dart';
import 'sim_common.dart';

/// Trafik lambası: zamanlayıcıyla sıralı faz mantığı.
class TrafficSim extends StatefulWidget {
  const TrafficSim({super.key});

  @override
  State<TrafficSim> createState() => _TrafficSimState();
}

class _TrafficSimState extends State<TrafficSim> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _running = false;
  bool _fast = false;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
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
    setState(() => _t += dt * (_fast ? 4 : 1));
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

  void _nextPhase() {
    final cur = trafficAt(_t);
    setState(() => _t += cur.remaining + 0.001);
  }

  @override
  Widget build(BuildContext context) {
    final col = SimColors.of(context);
    final at = trafficAt(_t);
    final phase = trafficPhases[at.index];
    return SimScaffold(
      title: 'Trafik lambası (PLC mantığı)',
      aspect: 1.6,
      painter: _TrafficPainter(col: col, a: phase.a, b: phase.b),
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
                onPressed: _nextPhase,
                icon: const Icon(Icons.skip_next),
                label: const Text('Sonraki faz'),
              ),
            ),
          ],
        ),
        SwitchListTile(
          title: const Text('Hızlı mod (4×)'),
          value: _fast,
          onChanged: (v) => setState(() => _fast = v),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _t = 0),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Başa sar'),
          ),
        ),
      ],
      info: [
        InfoCard(
          title: 'Mevcut faz',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusLine('Faz ${at.index + 1} / ${trafficPhases.length}', phase.name, active: true),
              StatusLine('Fazın kalan süresi', '${fmtNum(at.remaining, sig: 3)} sn'),
              StatusLine('Döngü süresi', '${fmtNum(trafficCycleSeconds)} sn'),
            ],
          ),
        ),
        const InfoCard(
          title: 'Mantık',
          child: Text(
            'Zamanlayıcı fazları sırayla çalıştırır. Hiçbir fazda iki yön aynı anda yeşil veya sarı olmaz. '
            '“Hepsi kırmızı” aralığı, kavşaktaki araçların boşalması için güvenlik payıdır. '
            'Gerçek sinyalizasyon sistemleri özel standartlara ve emniyet gereksinimlerine tabidir.',
          ),
        ),
      ],
    );
  }
}

class _TrafficPainter extends CustomPainter {
  final SimColors col;
  final Light a;
  final Light b;
  _TrafficPainter({required this.col, required this.a, required this.b});

  void _signal(Canvas canvas, Offset c, double h, Light lit, String label) {
    final box = Rect.fromCenter(center: c, width: h * 0.34, height: h * 0.74);
    canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(12)), fillPaint(const Color(0xFF263238)));
    final colors = {
      Light.red: const Color(0xFFE5484D),
      Light.yellow: const Color(0xFFFFC107),
      Light.green: const Color(0xFF2E9E4F),
    };
    var i = 0;
    for (final l in [Light.red, Light.yellow, Light.green]) {
      final cy = box.top + box.height * (0.2 + 0.3 * i);
      final on = l == lit;
      canvas.drawCircle(Offset(c.dx, cy), h * 0.085, fillPaint(on ? colors[l]! : colors[l]!.withValues(alpha: 0.18)));
      i++;
    }
    drawLabel(canvas, label, Offset(c.dx, box.bottom + 14), color: col.text, weight: FontWeight.w700);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Yollar
    canvas.drawRect(Rect.fromLTWH(0, h * 0.42, w, h * 0.16), fillPaint(col.off.withValues(alpha: 0.25)));
    canvas.drawRect(Rect.fromLTWH(w * 0.44, 0, w * 0.12, h), fillPaint(col.off.withValues(alpha: 0.25)));
    _signal(canvas, Offset(w * 0.22, h * 0.42), h * 0.9, a, 'A yönü');
    _signal(canvas, Offset(w * 0.78, h * 0.42), h * 0.9, b, 'B yönü');
  }

  @override
  bool shouldRepaint(covariant _TrafficPainter old) => old.a != a || old.b != b;
}
