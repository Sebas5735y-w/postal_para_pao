import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/messages.dart';

/// Representa una carta ya entregada, guardada en el archivo/álbum.
class DeliveredLetter {
  final DateTime date;
  final LoveMessage message;
  final bool opened;

  DeliveredLetter({
    required this.date,
    required this.message,
    required this.opened,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'messageId': message.id,
        'opened': opened,
      };

  factory DeliveredLetter.fromJson(Map<String, dynamic> json) {
    final id = json['messageId'] as int;
    final msg = loveMessages.firstWhere((m) => m.id == id,
        orElse: () => loveMessages.first);
    return DeliveredLetter(
      date: DateTime.parse(json['date'] as String),
      message: msg,
      opened: json['opened'] as bool? ?? false,
    );
  }
}

/// Controla qué carta corresponde a cada día usando una "bolsa" que se
/// baraja y se va vaciando sin repetir, hasta que se agota y se vuelve
/// a barajar para un nuevo ciclo.
class MessageService {
  static const _kQueueKey = 'message_queue_v1';
  static const _kHistoryKey = 'letter_history_v1';
  static const _kLastAssignedDateKey = 'last_assigned_date_v1';
  static const _kTodayMessageIdKey = 'today_message_id_v1';

  Future<List<int>> _loadQueue(SharedPreferences prefs) async {
    final raw = prefs.getStringList(_kQueueKey);
    if (raw == null || raw.isEmpty) {
      return _shuffledIds();
    }
    return raw.map(int.parse).toList();
  }

  List<int> _shuffledIds() {
    final ids = loveMessages.map((m) => m.id).toList();
    ids.shuffle(Random());
    return ids;
  }

  Future<void> _saveQueue(SharedPreferences prefs, List<int> queue) async {
    await prefs.setStringList(_kQueueKey, queue.map((e) => e.toString()).toList());
  }

  Future<List<DeliveredLetter>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kHistoryKey) ?? [];
    return raw
        .map((s) => DeliveredLetter.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _saveHistory(SharedPreferences prefs, List<DeliveredLetter> history) async {
    final raw = history.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_kHistoryKey, raw);
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Devuelve la carta de hoy. Si ya se asignó una para hoy, la reutiliza
  /// (así la notificación y la app siempre coinciden). Si es un día nuevo,
  /// saca la siguiente de la bolsa (rebarajando si se acabó) y la guarda
  /// en el historial.
  Future<LoveMessage> getTodayMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final lastAssigned = prefs.getString(_kLastAssignedDateKey);

    if (lastAssigned == todayKey) {
      final id = prefs.getInt(_kTodayMessageIdKey);
      if (id != null) {
        return loveMessages.firstWhere((m) => m.id == id,
            orElse: () => loveMessages.first);
      }
    }

    var queue = await _loadQueue(prefs);
    if (queue.isEmpty) {
      queue = _shuffledIds();
    }
    final nextId = queue.removeAt(0);
    await _saveQueue(prefs, queue);
    await prefs.setString(_kLastAssignedDateKey, todayKey);
    await prefs.setInt(_kTodayMessageIdKey, nextId);

    final message =
        loveMessages.firstWhere((m) => m.id == nextId, orElse: () => loveMessages.first);

    final history = await getHistory();
    history.insert(
      0,
      DeliveredLetter(date: DateTime(now.year, now.month, now.day), message: message, opened: false),
    );
    await _saveHistory(prefs, history);

    return message;
  }

  /// Marca la carta de hoy como abierta (se llama cuando rompe el sello).
  Future<void> markTodayAsOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    if (history.isEmpty) return;
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final updated = history.map((h) {
      if (_dateKey(h.date) == todayKey) {
        return DeliveredLetter(date: h.date, message: h.message, opened: true);
      }
      return h;
    }).toList();
    await _saveHistory(prefs, updated);
  }

  Future<bool> isTodayOpened() async {
    final history = await getHistory();
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final todayEntry = history.where((h) => _dateKey(h.date) == todayKey);
    if (todayEntry.isEmpty) return false;
    return todayEntry.first.opened;
  }

  /// Cuenta cuántos días seguidos (incluyendo hoy si ya la abrió) ha abierto
  /// su cartita, contando hacia atrás desde hoy. Se corta apenas encuentra
  /// un día sin abrir o un hueco en el calendario.
  Future<int> getStreak() async {
    final history = await getHistory(); // ya viene ordenado, más reciente primero
    if (history.isEmpty) return 0;

    var streak = 0;
    var expected = DateTime.now();
    for (final letter in history) {
      final letterKey = _dateKey(letter.date);
      final expectedKey = _dateKey(expected);
      if (letterKey != expectedKey) break;
      if (!letter.opened) break;
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
