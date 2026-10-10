import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/sim_logic.dart';
import '../draw_utils.dart';
import 'sim_common.dart';

/// Pil – anahtar – sigorta – lamba devresi; kısa devre ve aşırı akım denemesi.
class BasicCircuitSim extends StatefulWidget {
  const BasicCircuitSim({super.key});

  @override
  State<BasicCircuitSim> createState() => _BasicCircuitSimState();
}

class _BasicCircuitSimState extends State<BasicCircuitSim> {
  bool _switch = false;
  bool _short = false;
  bool _blown = false;
  double _volts = 12;
  double _lamp = 12;
  double _fuse = 2;

  CircuitState _state() => basicCircuit(
        volts: _volts,
        lampOhms: _lamp,
        switchClosed: _switch,
        shorted: _short,
        fuseA: _fuse,
        fuseBlown: _blown,
      );

  /// Girişler değişince devreyi yeniden değerlendirir; sigorta attıysa kalıcı hale getirir.
  void _apply(VoidCallback change) {
    setState(() {
      change();
      _blown = _state().fuseBlown;
    });
  }

  String _message(CircuitState s) {
    if (_blown) return 'Sigorta attı. Neden (kısa devre veya aşırı akım) giderilmeden sigortayı değiştirmeyin.';
    if (!_switch) return 'Anahtar açık: devre tamamlanmadı, akım yok.';
    if (_short) return 'Kısa devre sigortayı attıracak.';
    return 'Devre kapalı: akım ${fmtEng(s.current, 'A')}, lamba gücü ${fmtEng(s.lampPower, 'W')}.';
  }

  @override
  Widget build(BuildContext context) {
    final col = SimColors.of(context);
    final s = _state();
    return SimScaffold(
      title: 'Temel devre: pil, anahtar, sigorta, lamba',
      painter: _CircuitPainter(col: col, s: s, switchClosed: _switch, shorted: _short, blown: _blown),
      controls: [
        SwitchListTile(
          title: const Text('Anahtar (S1) kapalı'),
          value: _switch,
          onChanged: (v) => _apply(() => _switch = v),
        ),
        SwitchListTile(
          title: const Text('Lambayı kısa devre et'),
          subtitle: const Text('Çok düşük dirençli bir yol oluşturur'),
          value: _short,
          onChanged: (v) => _apply(() => _short = v),
        ),
        Text('Pil gerilimi: ${fmtNum(_volts)} V'),
        Slider(
          min: 3,
          max: 24,
          divisions: 21,
          value: _volts,
          label: '${fmtNum(_volts)} V',
          onChanged: (v) => _apply(() => _volts = v),
        ),
        Text('Lamba direnci: ${fmtNum(_lamp)} Ω'),
        Slider(
          min: 6,
          max: 48,
          divisions: 42,
          value: _lamp,
          label: '${fmtNum(_lamp)} Ω',
          onChanged: (v) => _apply(() => _lamp = v),
        ),
        Row(
          children: [
            const Text('Sigorta: '),
            const SizedBox(width: 8),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 0.5, label: Text('0,5 A')),
                ButtonSegment(value: 2, label: Text('2 A')),
                ButtonSegment(value: 5, label: Text('5 A')),
              ],
              selected: {_fuse},
              onSelectionChanged: (v) => _apply(() => _fuse = v.first),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _blown
              ? () => setState(() {
                    _blown = false;
                    _short = false;
                  })
              : null,
          icon: const Icon(Icons.build_circle_outlined),
          label: const Text('Arızayı gider ve sigortayı değiştir'),
        ),
      ],
      info: [
        InfoCard(
          title: 'Durum',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusLine('Akım (I)', fmtEng(s.current, 'A'), active: s.current > 0),
              StatusLine('Lamba gerilimi', fmtEng(s.lampVoltage, 'V'), active: s.lampVoltage > 0),
              StatusLine('Lamba gücü (P = V · I)', fmtEng(s.lampPower, 'W'), active: s.lampPower > 0),
              const SizedBox(height: 6),
              Text(_message(s)),
            ],
          ),
        ),
        const InfoCard(
          title: 'Ne öğreniyoruz?',
          child: Text(
            'Akım yalnızca kapalı devrede akar. Lamba 12 V için tasarlanmış kabul edilir; daha yüksek gerilimde parlaklık artar. '
            'Direnç artarsa akım azalır (I = V / R). Kısa devrede akım çok yükselir ve sigorta devreyi açar; '
            'yüksek gerilim ve düşük lamba direnci birleşince aşırı akım da sigortayı attırabilir.',
          ),
        ),
      ],
    );
  }
}

class _CircuitPainter extends CustomPainter {
  final SimColors col;
  final CircuitState s;
  final bool switchClosed;
  final bool shorted;
  final bool blown;
  _CircuitPainter({required this.col, required this.s, required this.switchClosed, required this.shorted, required this.blown});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final l = 0.12 * w;
    final r = 0.88 * w;
    final t = 0.2 * h;
    final b = 0.8 * h;
    final on = s.current > 0;
    Offset o(double x, double y) => Offset(x, y);

    // Sol: pil
    wire(canvas, o(l, t), o(l, 0.42 * h), on, col);
    wire(canvas, o(l, 0.5 * h), o(l, b), on, col);
    canvas.drawLine(o(l - 20, 0.42 * h), o(l + 20, 0.42 * h), strokePaint(col.text, 3));
    canvas.drawLine(o(l - 11, 0.5 * h), o(l + 11, 0.5 * h), strokePaint(col.text, 3));
    drawLabel(canvas, '+', o(l + 30, 0.4 * h), size: 14, color: col.text, weight: FontWeight.w700);
    drawLabel(canvas, 'Pil', o(l, 0.62 * h), color: col.text);

    // Üst: anahtar
    wire(canvas, o(l, t), o(0.4 * w, t), on, col);
    drawContact(canvas, o(0.5 * w, t), 0.1 * w, closed: switchClosed, nc: false, col: col, on: on);
    wire(canvas, o(0.6 * w, t), o(r, t), on, col);
    drawLabel(canvas, 'S1', o(0.5 * w, t - 0.1 * h), color: col.text);

    // Sağ: lamba
    wire(canvas, o(r, t), o(r, 0.38 * h), on, col);
    drawLamp(canvas, o(r, 0.5 * h), 0.09 * h, s.brightness, col);
    wire(canvas, o(r, 0.62 * h), o(r, b), on, col);
    drawLabel(canvas, 'H1', o(r - 0.09 * w, 0.5 * h), color: col.text);

    // Alt: sigorta
    wire(canvas, o(r, b), o(0.62 * w, b), on, col);
    wire(canvas, o(0.38 * w, b), o(l, b), on, col);
    final fr = Rect.fromLTRB(0.38 * w, b - 9, 0.62 * w, b + 9);
    canvas.drawRect(fr, strokePaint(blown ? col.bad : col.text, 2.4));
    if (blown) {
      canvas.drawLine(o(0.46 * w, b - 14), o(0.54 * w, b + 14), strokePaint(col.bad, 3));
      canvas.drawLine(o(0.54 * w, b - 14), o(0.46 * w, b + 14), strokePaint(col.bad, 3));
    } else {
      canvas.drawLine(o(0.38 * w, b), o(0.62 * w, b), strokePaint(on ? col.on : col.text, 2));
    }
    drawLabel(canvas, 'F1', o(0.5 * w, b + 0.11 * h), color: col.text);

    // Kısa devre kolu
    if (shorted) {
      final sc = blown ? col.bad : col.on;
      canvas.drawLine(o(0.74 * w, t), o(0.74 * w, b), strokePaint(sc, 3.2));
      drawLabel(canvas, 'Kısa\ndevre', o(0.74 * w - 0.07 * w, 0.5 * h), color: col.bad, weight: FontWeight.w700);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter old) => true;
}
