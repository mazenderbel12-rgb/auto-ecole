import '../datasources/seance_remote_data_source.dart';
import '../models/seance_model.dart';

class SeanceService {
  final SeanceRemoteDataSource _remote;

  SeanceService(this._remote);

  Future<List<Seance>> getAllSeances() async {
    final items = await _remote.fetchAll();
    return items
        .whereType<Map>()
        .map((item) => Seance.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Seance>> getSeancesByDate(DateTime date) async {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final dateStr = '${date.year}-$mm-$dd';
    final items = await _remote.fetchByDate(dateStr);
    final mapped = items
        .whereType<Map>()
        .map((item) => Seance.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    if (mapped.isNotEmpty) return mapped;

    final fallbackItems = await _remote.fetchAll();
    final fallback = fallbackItems
        .whereType<Map>()
        .map((item) => Seance.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return fallback.where((s) => _sameDate(s.date, date)).toList();
  }

  Future<Seance> addSeance(SeanceDraft draft) async {
    final payload = {
      'DateSeance': _formatDate(draft.date),
      'HeureSeance': _formatTime(draft.heure),
      'TypeSeance': draft.type,
      'Id_Candidat': draft.candidatId,
      'Id_Personnel': draft.personnelId,
      'Duree': (draft.duree == null || draft.duree!.trim().isEmpty) ? '1' : draft.duree,
      if (draft.remarque != null && draft.remarque!.trim().isNotEmpty) 'Remarque': draft.remarque,
    };
    final data = await _remote.createSeance(payload);
    return Seance.fromJson(data);
  }

  Future<Seance> updateSeance(Seance seance) async {
    final data = await _remote.updateSeance(seance.id, seance.toJson());
    return Seance.fromJson(data);
  }

  Future<Seance> updateStatus(String id, String statut) async {
    final data = await _remote.updateSeance(id, {'Statut': statut});
    return Seance.fromJson(data);
  }

  Future<void> deleteSeance(String id) async {
    await _remote.deleteSeance(id);
  }

  static String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  static String _formatTime(String time) {
    final parts = time.split(':');
    final hh = (parts.isNotEmpty ? parts[0] : '09').padLeft(2, '0');
    final mm = (parts.length > 1 ? parts[1] : '00').padLeft(2, '0');
    return '$hh:$mm:00';
  }

  static bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
