import 'package:flutter/material.dart';

import '../data/content_models.dart';
import '../data/storage.dart';

/// Mini test: her soruda anında doğru/yanlış geri bildirimi ve gerçek puanlama.
class QuizCard extends StatefulWidget {
  final String id;
  final List<QuizQ> quiz;
  const QuizCard({super.key, required this.id, required this.quiz});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  late List<int?> _chosen = List<int?>.filled(widget.quiz.length, null);

  bool get _done => _chosen.every((e) => e != null);

  void _pick(int q, int o) {
    if (_chosen[q] != null) return;
    setState(() => _chosen[q] = o);
    if (_done) {
      appStorage.saveScore(widget.id, scoreQuiz(widget.quiz, _chosen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const good = Color(0xFF2E9E4F);
    final score = scoreQuiz(widget.quiz, _chosen);
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
            Text('Mini test', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (var qi = 0; qi < widget.quiz.length; qi++) ...[
              Text('${qi + 1}. ${widget.quiz[qi].q}', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              for (var oi = 0; oi < widget.quiz[qi].options.length; oi++)
                _option(context, qi, oi, good),
              if (_chosen[qi] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    '${_chosen[qi] == widget.quiz[qi].answer ? 'Doğru. ' : 'Yanlış. '}${widget.quiz[qi].explain}',
                    style: tt.bodySmall?.copyWith(
                        color: _chosen[qi] == widget.quiz[qi].answer ? good : cs.error, height: 1.35),
                  ),
                ),
              const SizedBox(height: 12),
            ],
            if (_done) ...[
              const Divider(),
              Text('Puanınız: $score / ${widget.quiz.length}',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() => _chosen = List<int?>.filled(widget.quiz.length, null)),
                icon: const Icon(Icons.replay),
                label: const Text('Testi tekrarla'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context, int qi, int oi, Color good) {
    final cs = Theme.of(context).colorScheme;
    final chosen = _chosen[qi];
    final answered = chosen != null;
    final isAnswer = widget.quiz[qi].answer == oi;
    final isChosen = chosen == oi;
    IconData icon = Icons.radio_button_unchecked;
    Color? color;
    if (answered && isAnswer) {
      icon = Icons.check_circle;
      color = good;
    } else if (answered && isChosen) {
      icon = Icons.cancel;
      color = cs.error;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: answered ? null : () => _pick(qi, oi),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.quiz[qi].options[oi])),
          ],
        ),
      ),
    );
  }
}
