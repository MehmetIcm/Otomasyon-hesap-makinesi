import 'package:flutter/material.dart';

import '../widgets.dart';

const String kSimDisclaimer =
    'Bu bir eğitim simülasyonudur; gerçek donanım testi değildir ve gerçek bir PLC veya emniyet sisteminin yerini tutmaz. '
    'Gerçek devre kurulumu yetkin elektrik personelince, geçerli standartlara göre yapılmalıdır.';

/// Tüm simülasyonlar için ortak sayfa iskeleti.
class SimScaffold extends StatelessWidget {
  final String title;
  final double aspect;
  final CustomPainter painter;
  final List<Widget> controls;
  final List<Widget> info;
  const SimScaffold({
    super.key,
    required this.title,
    required this.painter,
    required this.controls,
    this.info = const [],
    this.aspect = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const InfoBanner(icon: Icons.school_outlined, text: kSimDisclaimer),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: aspect,
                child: CustomPaint(painter: painter, size: Size.infinite),
              ),
            ),
            const SizedBox(height: 12),
            ...controls,
            if (info.isNotEmpty) ...[const SizedBox(height: 12), ...info],
          ],
        ),
      ),
    );
  }
}

/// Basılı tutma davranışlı buton (Start/Stop gibi darbe butonları için).
class HoldButton extends StatefulWidget {
  final String label;
  final Color color;
  final ValueChanged<bool> onChanged;
  const HoldButton({super.key, required this.label, required this.color, required this.onChanged});

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _down ? widget.color : widget.color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black26, width: _down ? 3 : 1),
        ),
        child: Text(widget.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const InfoCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusLine extends StatelessWidget {
  final String label;
  final String value;
  final bool active;
  const StatusLine(this.label, this.value, {super.key, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: active ? const Color(0xFF2E9E4F) : Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
