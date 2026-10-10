import 'package:flutter/material.dart';

import 'sim_basic.dart';
import 'sim_motor.dart';
import 'sim_pump.dart';
import 'sim_startstop.dart';
import 'sim_traffic.dart';

class SimInfo {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function() builder;
  const SimInfo(this.id, this.title, this.subtitle, this.icon, this.builder);
}

final List<SimInfo> allSims = [
  SimInfo('basic', 'Temel devre: pil, anahtar, sigorta, lamba',
      'Açık/kapalı devre, Ohm kanunu, kısa devre ve sigorta', Icons.lightbulb_outline,
      () => const BasicCircuitSim()),
  SimInfo('startstop', 'Start-Stop mühürleme devresi',
      'Kontaktör bobini, yardımcı kontak, termik röle ve acil stop', Icons.toggle_on_outlined,
      () => const StartStopSim()),
  SimInfo('motor', 'Üç fazlı asenkron motor',
      'Döner alan, senkron hız, kayma, yük ve yön', Icons.settings,
      () => const MotorRunSim()),
  SimInfo('pump', 'Depo seviye kontrolü ve pompa',
      'İki sensörlü histerezis, giriş/çıkış durumu', Icons.water_drop_outlined,
      () => const PumpSim()),
  SimInfo('traffic', 'Trafik lambası (PLC mantığı)',
      'Zamanlayıcıyla sıralı fazlar ve güvenlik aralığı', Icons.traffic_outlined,
      () => const TrafficSim()),
];

SimInfo? findSim(String id) {
  for (final s in allSims) {
    if (s.id == id) return s;
  }
  return null;
}

void openSim(BuildContext context, String id) {
  final s = findSim(id);
  if (s == null) return;
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s.builder()));
}
