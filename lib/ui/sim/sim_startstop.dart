import 'package:flutter/material.dart';

import '../../core/sim_logic.dart';
import '../draw_utils.dart';
import 'sim_common.dart';

/// Start-Stop mühürleme kumanda devresi (kontaktör, termik röle, acil stop).
class StartStopSim extends StatefulWidget {
  const StartStopSim({super.key});

  @override
  State<StartStopSim> createState() => _StartStopSimState();
}

class _StartStopSimState extends State<StartStopSim> {
  bool _coil = false;
  bool _start = false;
  bool _stop = false;
  bool _estop = false;
  bool _trip = false;

  void _eval(VoidCallback change) {
    setState(() {
      change();
      _coil = startStopNext(
        coil: _coil,
        startPressed: _start,
        stopPressed: _stop,
        eStopPressed: _estop,
        thermalTripped: _trip,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final col = SimColors.of(context);
    final status = startStopStatus(
      coil: _coil,
      startPressed: _start,
      stopPressed: _stop,
      eStopPressed: _estop,
      thermalTripped: _trip,
    );
    return SimScaffold(
      title: 'Start-Stop mühürleme devresi',
      aspect: 1.25,
      painter: _LadderPainter(col: col, coil: _coil, start: _start, stop: _stop, estop: _estop, trip: _trip),
      controls: [
        Row(
          children: [
            Expanded(child: HoldButton(label: 'START (NO)', color: const Color(0xFF2E9E4F), onChanged: (v) => _eval(() => _start = v))),
            const SizedBox(width: 12),
            Expanded(child: HoldButton(label: 'STOP (NC)', color: const Color(0xFFE5484D), onChanged: (v) => _eval(() => _stop = v))),
          ],
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          title: const Text('Acil stop basılı (kilitli)'),
          value: _estop,
          onChanged: (v) => _eval(() => _estop = v),
        ),
        SwitchListTile(
          title: const Text('Aşırı yük: termik röle attı'),
          value: _trip,
          onChanged: (v) => _eval(() => _trip = v),
        ),
      ],
      info: [
        InfoCard(
          title: 'Durum',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusLine('K1 kontaktör bobini', _coil ? 'Enerjili' : 'Enerjisiz', active: _coil),
              StatusLine('K1 mühür kontağı (13-14)', _coil ? 'Kapalı' : 'Açık', active: _coil),
              StatusLine('Motor', _coil ? 'Çalışıyor' : 'Duruyor', active: _coil),
              const SizedBox(height: 6),
              Text(status),
            ],
          ),
        ),
        const InfoCard(
          title: 'Adım adım',
          child: Text(
            '1. START’a basın: bobin enerjilenir.\n'
            '2. K1 enerjilenince 13-14 yardımcı kontağı kapanır ve START’a paralel bir yol açar (mühür).\n'
            '3. START’ı bırakın: bobin mühürden beslenmeye devam eder.\n'
            '4. STOP’a basın: bobin kesilir, mühür çözülür; bırakınca motor kendiliğinden başlamaz.\n'
            '5. Acil stop veya termik röle bobin hattını keser; neden giderilip START’a basılmadan motor çalışmaz.\n\n'
            'Not: Kontaklar fiziksel durumlarıyla çizilir. NO kontak enerjisizken açık, NC kontak kapalıdır; '
            'K1 yardımcı kontağı yalnızca bobin enerjiliyken kapanır.',
          ),
        ),
      ],
    );
  }
}

class _LadderPainter extends CustomPainter {
  final SimColors col;
  final bool coil;
  final bool start;
  final bool stop;
  final bool estop;
  final bool trip;
  _LadderPainter({required this.col, required this.coil, required this.start, required this.stop, required this.estop, required this.trip});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset o(double x, double y) => Offset(x, y);
    final half = 0.04 * w;
    final r1 = 0.3 * h;
    final r2 = 0.56 * h;
    final r3 = 0.82 * h;
    final lx = 0.04 * w;
    final rx = 0.96 * w;

    // Enerji yolu
    final e0 = true;
    final e1 = e0 && !trip;
    final e2 = e1 && !estop;
    final e3 = e2 && !stop;
    final startOn = e3 && start;
    final auxOn = e3 && coil;
    final e4 = startOn || auxOn;

    // Raylar
    canvas.drawLine(o(lx, 0.1 * h), o(lx, 0.94 * h), strokePaint(col.on, 3.6));
    canvas.drawLine(o(rx, 0.1 * h), o(rx, 0.94 * h), strokePaint(col.off, 3.2));
    drawLabel(canvas, 'L+', o(lx + 12, 0.05 * h), color: col.text, weight: FontWeight.w700);
    drawLabel(canvas, '0 V', o(rx - 14, 0.05 * h), color: col.text, weight: FontWeight.w700);

    // Rung 1: termik – acil stop – stop
    final xT = 0.15 * w;
    final xE = 0.29 * w;
    final xS = 0.43 * w;
    wire(canvas, o(lx, r1), o(xT - half, r1), e0, col);
    drawContact(canvas, o(xT, r1), half, closed: !trip, nc: true, col: col, on: e1);
    wire(canvas, o(xT + half, r1), o(xE - half, r1), e1, col);
    drawContact(canvas, o(xE, r1), half, closed: !estop, nc: true, col: col, on: e2);
    wire(canvas, o(xE + half, r1), o(xS - half, r1), e2, col);
    drawContact(canvas, o(xS, r1), half, closed: !stop, nc: true, col: col, on: e3);
    final j1 = 0.52 * w;
    wire(canvas, o(xS + half, r1), o(j1, r1), e3, col);
    wire(canvas, o(j1, r1), o(j1, r2), e3, col);

    // Start (NO) paralel K1 yardımcı kontağı
    final xB = 0.64 * w;
    wire(canvas, o(j1, r1), o(xB - half, r1), e3, col);
    drawContact(canvas, o(xB, r1), half, closed: start, nc: false, col: col, on: startOn);
    wire(canvas, o(j1, r2), o(xB - half, r2), e3, col);
    drawContact(canvas, o(xB, r2), half, closed: coil, nc: false, col: col, on: auxOn);
    final j2 = 0.76 * w;
    wire(canvas, o(xB + half, r1), o(j2, r1), startOn, col);
    wire(canvas, o(xB + half, r2), o(j2, r2), auxOn, col);
    wire(canvas, o(j2, r2), o(j2, r1), e4, col);

    // Bobin
    final xC = 0.86 * w;
    wire(canvas, o(j2, r1), o(xC - 0.05 * w, r1), e4, col);
    drawCoilBox(canvas, o(xC, r1), 0.1 * w, 0.12 * h, coil, 'K1', col);
    wire(canvas, o(xC + 0.05 * w, r1), o(rx, r1), e4, col);

    // Rung 2: K1 ikinci yardımcı kontak → lamba
    final x2 = 0.35 * w;
    wire(canvas, o(lx, r3), o(x2 - half, r3), e0, col);
    drawContact(canvas, o(x2, r3), half, closed: coil, nc: false, col: col, on: coil);
    wire(canvas, o(x2 + half, r3), o(0.6 * w - 0.045 * h, r3), coil, col);
    drawLamp(canvas, o(0.6 * w, r3), 0.045 * h + 4, coil ? 1 : 0, col);
    wire(canvas, o(0.6 * w + 0.045 * h + 4, r3), o(rx, r3), coil, col);

    // Etiketler
    final y = 0.12 * h;
    drawLabel(canvas, 'F2 termik\n95-96 NC', o(xT, r1 - y), color: col.text, size: 10);
    drawLabel(canvas, 'S0 acil stop\nNC', o(xE, r1 - y), color: col.text, size: 10);
    drawLabel(canvas, 'S1 stop\nNC', o(xS, r1 - y), color: col.text, size: 10);
    drawLabel(canvas, 'S2 start NO', o(xB, r1 - y * 0.8), color: col.text, size: 10);
    drawLabel(canvas, 'K1 13-14\n(mühür)', o(xB, r2 + y), color: col.text, size: 10);
    drawLabel(canvas, 'K1 23-24', o(x2, r3 - y * 0.8), color: col.text, size: 10);
    drawLabel(canvas, 'H1 motor\nçalışıyor', o(0.6 * w, r3 + 0.1 * h), color: col.text, size: 10);
    drawLabel(canvas, 'Kumanda devresi', o(0.5 * w, 0.02 * h + 4), color: col.text, size: 11, weight: FontWeight.w700);
  }

  @override
  bool shouldRepaint(covariant _LadderPainter old) => true;
}
