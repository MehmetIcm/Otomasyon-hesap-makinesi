import 'package:flutter_test/flutter_test.dart';
import 'package:pro/calculators/registry.dart';
import 'package:pro/data/content.dart';

void main() {
  test('ders kimlikleri benzersiz', () {
    final ids = allLessons.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(allLessons.length, greaterThanOrEqualTo(20));
  });

  test('her dersin 3 soruluk testi ve geçerli doğru cevabı var', () {
    for (final l in allLessons) {
      expect(l.quiz.length, 3, reason: l.id);
      for (final q in l.quiz) {
        expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: '${l.id}: ${q.q}');
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.explain, isNotEmpty);
      }
      expect(l.keywords.length, inInclusiveRange(3, 6), reason: l.id);
      expect(l.definition, isNotEmpty);
    }
  });

  test('ilgili ders, araç ve simülasyon bağlantıları geçerli', () {
    for (final l in allLessons) {
      for (final r in l.related) {
        expect(findLesson(r), isNotNull, reason: '${l.id} -> $r');
      }
      if (l.calcId != null) expect(findCalc(l.calcId!), isNotNull, reason: '${l.id} -> ${l.calcId}');
      if (l.simId != null) expect(kSimIds.contains(l.simId), isTrue, reason: '${l.id} -> ${l.simId}');
    }
  });

  test('sözlük bağlantıları ve benzersizlik', () {
    final ids = glossaryTerms.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final t in glossaryTerms) {
      expect(t.definition, isNotEmpty);
      for (final r in t.related) {
        expect(findLesson(r), isNotNull, reason: '${t.term} -> $r');
      }
    }
  });

  test('projeler geçerli', () {
    for (final p in allProjects) {
      expect(p.quiz.length, 3, reason: p.id);
      expect(p.steps, isNotEmpty);
      expect(p.io, isNotEmpty);
      expect(p.simId == null || kSimIds.contains(p.simId), isTrue, reason: p.id);
      for (final c in p.calcIds) {
        expect(findCalc(c), isNotNull, reason: '${p.id} -> $c');
      }
      for (final q in p.quiz) {
        expect(q.answer, inInclusiveRange(0, q.options.length - 1));
      }
    }
  });

  test('test puanlama', () {
    final quiz = allLessons.first.quiz;
    expect(scoreQuiz(quiz, [quiz[0].answer, quiz[1].answer, quiz[2].answer]), 3);
    expect(scoreQuiz(quiz, [null, quiz[1].answer, (quiz[2].answer + 1) % 3]), 1);
    expect(scoreQuiz(quiz, []), 0);
  });
}
