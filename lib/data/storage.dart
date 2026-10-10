import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favoriler ve son kullanılanlar için yerel (cihaz içi) depolama.
class AppStorage extends ChangeNotifier {
  static const _favKey = 'favorites';
  static const _recentKey = 'recent';
  static const _doneKey = 'done';
  static const _scoreKey = 'scores';
  static const _lastKey = 'last_lesson';
  static const _maxRecent = 8;

  SharedPreferences? _prefs;
  List<String> _favorites = [];
  List<String> _recent = [];
  List<String> _done = [];
  Map<String, int> _scores = {};
  String? _lastLesson;

  List<String> get favorites => List.unmodifiable(_favorites);
  List<String> get recent => List.unmodifiable(_recent);
  List<String> get completed => List.unmodifiable(_done);
  String? get lastLesson => _lastLesson;
  int? bestScore(String id) => _scores[id];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      _favorites = prefs.getStringList(_favKey) ?? [];
      _recent = prefs.getStringList(_recentKey) ?? [];
      _done = prefs.getStringList(_doneKey) ?? [];
      _lastLesson = prefs.getString(_lastKey);
      _scores = {};
      for (final e in prefs.getStringList(_scoreKey) ?? const <String>[]) {
        final i = e.lastIndexOf('=');
        if (i > 0) {
          final v = int.tryParse(e.substring(i + 1));
          if (v != null) _scores[e.substring(0, i)] = v;
        }
      }
    } catch (_) {
      // Depolama kullanılamazsa uygulama bellek içi çalışmaya devam eder.
    }
  }

  bool isFavorite(String id) => _favorites.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favorites.contains(id)) {
      _favorites = _favorites.where((e) => e != id).toList();
    } else {
      _favorites = [..._favorites, id];
    }
    notifyListeners();
    await _prefs?.setStringList(_favKey, _favorites);
  }

  Future<void> addRecent(String id) async {
    _recent = [id, ..._recent.where((e) => e != id)];
    if (_recent.length > _maxRecent) {
      _recent = _recent.sublist(0, _maxRecent);
    }
    notifyListeners();
    await _prefs?.setStringList(_recentKey, _recent);
  }

  bool isCompleted(String id) => _done.contains(id);

  /// Dersi veya projeyi tamamlandı olarak işaretler / işareti kaldırır.
  Future<void> setCompleted(String id, bool value) async {
    final has = _done.contains(id);
    if (value == has) return;
    _done = value ? [..._done, id] : _done.where((e) => e != id).toList();
    notifyListeners();
    await _prefs?.setStringList(_doneKey, _done);
  }

  /// Mini test puanını kaydeder (en iyi puan korunur).
  Future<void> saveScore(String id, int score) async {
    final old = _scores[id];
    if (old == null || score > old) {
      _scores[id] = score;
      await _prefs?.setStringList(
          _scoreKey, [for (final e in _scores.entries) '${e.key}=${e.value}']);
    }
    notifyListeners();
  }

  Future<void> setLastLesson(String id) async {
    _lastLesson = id;
    await _prefs?.setString(_lastKey, id);
  }

  Future<void> clearRecent() async {
    _recent = [];
    notifyListeners();
    await _prefs?.setStringList(_recentKey, _recent);
  }
}

final AppStorage appStorage = AppStorage();
