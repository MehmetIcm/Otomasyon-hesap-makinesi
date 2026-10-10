/// Ortak içerik modelleri: dersler, sözlük, projeler ve mini testler.
library;

class QuizQ {
  final String q;
  final List<String> options;
  final int answer;
  final String explain;
  const QuizQ(this.q, this.options, this.answer, this.explain);
}

enum LessonGroup {
  basics('Elektriğin temelleri'),
  components('Devre elemanları'),
  control('Kumanda ve pano'),
  motor('Asenkron motor'),
  plc('PLC ve otomasyon'),
  cables('Kablolar');

  final String title;
  const LessonGroup(this.title);
}

class Lesson {
  final String id;
  final LessonGroup group;
  final String title;
  final List<String> keywords;
  final String definition;
  final String whatFor;
  final String how;
  final String example;

  /// Sembol çizici için kimlik (symbols.dart), yoksa null.
  final String? symbol;
  final String? calcId;
  final String? simId;
  final List<QuizQ> quiz;
  final List<String> related;

  /// Güvenlik notu (varsa vurgulu gösterilir).
  final String safety;

  const Lesson({
    required this.id,
    required this.group,
    required this.title,
    required this.keywords,
    required this.definition,
    required this.whatFor,
    required this.how,
    required this.example,
    required this.quiz,
    this.symbol,
    this.calcId,
    this.simId,
    this.related = const [],
    this.safety = '',
  });
}

class GlossaryTerm {
  final String term;
  final String english;
  final String definition;
  final List<String> related;
  const GlossaryTerm(this.term, this.english, this.definition,
      [this.related = const []]);

  String get id => 'g:${term.toLowerCase()}';
}

class Project {
  final String id;
  final String title;
  final String purpose;
  final List<String> concepts;
  final List<String> parts;
  final String blockDiagram;
  final String ladder;
  final List<String> steps;
  final List<String> io;
  final List<String> tweaks;
  final String expected;
  final List<String> mistakes;
  final List<String> calcIds;
  final String? simId;
  final List<QuizQ> quiz;
  final String safety;

  const Project({
    required this.id,
    required this.title,
    required this.purpose,
    required this.concepts,
    required this.parts,
    required this.blockDiagram,
    required this.ladder,
    required this.steps,
    required this.io,
    required this.tweaks,
    required this.expected,
    required this.mistakes,
    required this.calcIds,
    required this.quiz,
    this.simId,
    this.safety = '',
  });
}

/// Test puanı: doğru sayısı.
int scoreQuiz(List<QuizQ> quiz, List<int?> chosen) {
  var n = 0;
  for (var i = 0; i < quiz.length && i < chosen.length; i++) {
    if (chosen[i] == quiz[i].answer) n++;
  }
  return n;
}
