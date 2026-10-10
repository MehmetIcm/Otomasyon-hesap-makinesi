import 'content_models.dart';
import 'glossary.dart';
import 'lessons_basic.dart';
import 'lessons_more.dart';
import 'projects.dart';

export 'content_models.dart';
export 'glossary.dart';
export 'projects.dart';

/// Tüm dersler (ortak içerik modeli).
final List<Lesson> allLessons = [...lessonsBasic, ...lessonsMore];

/// Uygulamadaki simülasyon kimlikleri.
const Set<String> kSimIds = {'basic', 'startstop', 'motor', 'pump', 'traffic'};

Lesson? findLesson(String id) {
  for (final l in allLessons) {
    if (l.id == id) return l;
  }
  return null;
}

Project? findProject(String id) {
  for (final p in allProjects) {
    if (p.id == id) return p;
  }
  return null;
}

GlossaryTerm? findTermById(String id) {
  for (final t in glossaryTerms) {
    if (t.id == id) return t;
  }
  return null;
}
