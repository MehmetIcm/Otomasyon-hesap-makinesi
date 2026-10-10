import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/storage.dart';
import '../models/calc_models.dart';
import 'calculator_page.dart';

const String kDisclaimer =
    'Bu uygulama yalnızca bilgilendirme ve ön hesap amaçlıdır. Gerçek tesisat, '
    'kablo kesiti ve koruma elemanı seçimlerinde ilgili ülke standartları, '
    'döşeme yöntemi, ortam sıcaklığı, kısa devre koşulları ve yetkili '
    'uzman kontrolü esas alınmalıdır.';

void openCalc(BuildContext context, CalcDef def) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => def.customBuilder != null
        ? def.customBuilder!()
        : CalculatorPage(def: def),
  ));
}

/// Bilgi / uyarı kutusu.
class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isError;
  const InfoBanner({
    super.key,
    required this.icon,
    required this.text,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isError ? cs.errorContainer : cs.secondaryContainer;
    final fg = isError ? cs.onErrorContainer : cs.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: fg, height: 1.3)),
          ),
        ],
      ),
    );
  }
}

/// Sonuç kartı: ana değer, diğer satırlar, formül, açıklama, kopyala/paylaş.
class ResultCard extends StatelessWidget {
  final String title;
  final CalcResult result;
  const ResultCard({super.key, required this.title, required this.result});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: result.toShareText(title)));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sonuç panoya kopyalandı.')),
    );
  }

  Future<void> _share(BuildContext context) async {
    try {
      await Share.share(result.toShareText(title), subject: title);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paylaşım başlatılamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final main = result.lines.first;
    final others = result.lines.skip(1).toList();
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SONUÇ',
                style: tt.labelSmall?.copyWith(
                    color: cs.primary, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(main.label, style: tt.bodyMedium),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SelectableText(
                main.text,
                style: tt.headlineMedium?.copyWith(
                    color: cs.primary, fontWeight: FontWeight.w700),
              ),
            ),
            if (others.isNotEmpty) ...[
              const Divider(height: 24),
              for (final l in others)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: Text(l.label, style: tt.bodyMedium)),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: SelectableText(
                          l.text,
                          textAlign: TextAlign.right,
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (result.warning.isNotEmpty) ...[
              const SizedBox(height: 12),
              InfoBanner(
                  icon: Icons.warning_amber_rounded,
                  text: result.warning,
                  isError: true),
            ],
            if (result.formula.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Kullanılan formül',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  result.formula,
                  style: tt.bodySmall?.copyWith(height: 1.5),
                ),
              ),
            ],
            if (result.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(result.note,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(context),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Kopyala'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _share(context),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Paylaş'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Liste öğesi: hesaplama adı, açıklama ve favori yıldızı.
class CalcTile extends StatelessWidget {
  final CalcDef def;
  const CalcTile({super.key, required this.def});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          child: Icon(def.icon),
        ),
        title: Text(def.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(def.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: ListenableBuilder(
          listenable: appStorage,
          builder: (context, _) {
            final fav = appStorage.isFavorite(def.id);
            return IconButton(
              tooltip: fav ? 'Favorilerden çıkar' : 'Favorilere ekle',
              icon: Icon(fav ? Icons.star : Icons.star_border,
                  color: fav ? Colors.amber.shade700 : null),
              onPressed: () => appStorage.toggleFavorite(def.id),
            );
          },
        ),
        onTap: () => openCalc(context, def),
      ),
    );
  }
}
