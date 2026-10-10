import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/format.dart';
import '../../core/sim_logic.dart';
import '../draw_utils.dart';
import 'sim_common.dart';

/// Üç fazlı asenkron motor: döner alan ve rotor animasyonu (basitleştirilmiş eğitim modeli).
class MotorRunSim extends StatefulWidget {
  const MotorRunSim({super.key});

  @override
  State<MotorRunSim> createState() => _MotorSimState();
}

class _MotorSimState extends State<MotorRunSim> with SingleTickerProviderStateMixin {
  static const _visualScale = 0.08; // gerçek devir/sn değerinin görsel ölçeği
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _running = false;
  bool _reverse = false;
  double _freq = 50;
  int _poleIdx = 1; // 4 kutup
  double _load = 50;
  double _fieldAngle = 0;
  double _rotorAngle = 0;

  int get _poles => 2 * (_poleIdx + 1);
  MotorSim get _sim => motorSim(freq: _freq, poles: _poles, loadPct: _load);

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
    final m = _sim;
    final dir = _reverse ? -1.0 : 1.0;
    setState(() {
      _fieldAngle += dir * 2 * math.pi * (m.ns / 60) * _visualScale * dt;
      _rotorAngle += dir * 2 * math.pi * (m.nr / 60) * _visualScale * dt;
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
    final m = _sim;
    final nr = _running ? m.nr : 0.0;
    return SimScaffold(
      title: 'Üç fazlı asenkron motor',
      aspect: 1.5,
      painter: _MotorPainter(col: col, poles: _poles, field: _fieldAngle, rotor: _rotorAngle, running: _running),
      controls: [
        FilledButton.icon(
          onPressed: _toggle,
          icon: Icon(_running ? Icons.stop : Icons.play_arrow),
          label: Text(_running ? 'Motoru durdur' : 'Motoru çalıştır'),
        ),
        SwitchListTile(
          title: const Text('Ters yön (iki fazın yeri değişir)'),
          value: _reverse,
          onChanged: (v) => setState(() => _reverse = v),
        ),
        Text('Frekans: ${fmtNum(_freq)} Hz'),
        Slider(
          min: 10,
          max: 60,
          divisions: 50,
          value: _freq,
          label: '${fmtNum(_freq)} Hz',
          onChanged: (v) => setState(() => _freq = v),
        ),
        Row(
          children: [
            const Text('Kutup sayısı: '),
            const SizedBox(width: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('2')),
                ButtonSegment(value: 1, label: Text('4')),
                ButtonSegment(value: 2, label: Text('6')),
                ButtonSegment(value: 3, label: Text('8')),
              ],
              selected: {_poleIdx},
              onSelectionChanged: (v) => setState(() => _poleIdx = v.first),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Yük: %${fmtNum(_load)}'),
        Slider(
          min: 0,
          max: 100,
          divisions: 20,
          value: _load,
          label: '%${fmtNum(_load)}',
          onChanged: (v) => setState(() => _load = v),
        ),
      ],
      info: [
        InfoCard(
          title: 'Hızlar',
          child: Column(
            children: [
              StatusLine('Senkron hız (ns = 120·f/p)', '${fmtNum(m.ns, sig: 5)} d/dk', active: _running),
              StatusLine('Kayma (s)', '%${fmtNum(m.slipPct, sig: 3)}', active: _running),
              StatusLine('Rotor hızı (nr)', '${fmtNum(nr, sig: 5)} d/dk', active: _running),
            ],
          ),
        ),
        const InfoCard(
          title: 'Nasıl okunur?',
          child: Text(
            'Renkli halka statorun döner manyetik alanını (kırmızı N, mavi S kutuplar) gösterir; iç kısım rotordur ve yeşil işaret rotor konumudur. '
            'Rotor alanı yakalamaya çalışır ama biraz geride kalır; bu fark kaymadır. Yük arttıkça kayma artar, frekans düşerse senkron hız düşer. '
            'Görsel dönüş hızı gerçek devirle orantılı ama yavaşlatılmıştır. Bu basit bir eğitim modelidir; motorun tüm elektromanyetik davranışını birebir göstermez.',
          ),
        ),
      ],
    );
  }
}

class _MotorPainter extends CustomPainter {
  final SimColors col;
  final int poles;
  final double field;
  final double rotor;
  final bool running;
  _MotorPainter({required this.col, required this.poles, required this.field, required this.rotor, required this.running});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final rad = math.min(size.width, size.height) * 0.42;
    final ring = rad * 0.9;
    final sweep = 2 * math.pi / poles;
    for (var i = 0; i < poles; i++) {
      final p = strokePaint(i.isEven ? const Color(0xFFE5484D) : const Color(0xFF3B82F6), rad * 0.2)
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(Rect.fromCircle(center: c, radius: ring), field + i * sweep, sweep * 0.96, false, p);
    }
    canvas.drawCircle(c, rad * 0.66, fillPaint(col.off.withValues(alpha: 0.15)));
    canvas.drawCircle(c, rad * 0.66, strokePaint(col.text, 2));
    for (var k = 0; k < 6; k++) {
      final a = rotor + k * math.pi / 3;
      canvas.drawLine(c, c + Offset(math.cos(a), math.sin(a)) * (rad * 0.62), strokePaint(col.text, 1.6));
    }
    canvas.drawCircle(c + Offset(math.cos(rotor), math.sin(rotor)) * (rad * 0.5), 6, fillPaint(col.good));
    canvas.drawCircle(c, 5, fillPaint(col.text));
    drawLabel(canvas, running ? 'Çalışıyor' : 'Durdu', Offset(c.dx, size.height - 12), color: col.text, weight: FontWeight.w700);
  }

  @override
  bool shouldRepaint(covariant _MotorPainter old) => true;
}
