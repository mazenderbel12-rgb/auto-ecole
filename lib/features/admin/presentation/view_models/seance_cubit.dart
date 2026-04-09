import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/models/seance_model.dart';
import '../../data/services/seance_service.dart';
import '../../data/services/user_service.dart';

class SeanceState {
  final DateTime selectedDate;
  final List<Seance> seances;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final List<AdminUser> candidats;
  final List<AdminUser> moniteurs;
  final Map<String, String> previousStatusById;

  const SeanceState({
    required this.selectedDate,
    required this.seances,
    required this.isLoading,
    required this.isSubmitting,
    required this.candidats,
    required this.moniteurs,
    required this.previousStatusById,
    this.error,
  });

  factory SeanceState.initial() {
    final today = DateTime.now();
    return SeanceState(
      selectedDate: DateTime(today.year, today.month, today.day),
      seances: const [],
      isLoading: false,
      isSubmitting: false,
      candidats: const [],
      moniteurs: const [],
      previousStatusById: const {},
      error: null,
    );
  }

  SeanceState copyWith({
    DateTime? selectedDate,
    List<Seance>? seances,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    List<AdminUser>? candidats,
    List<AdminUser>? moniteurs,
    Map<String, String>? previousStatusById,
  }) {
    return SeanceState(
      selectedDate: selectedDate ?? this.selectedDate,
      seances: seances ?? this.seances,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      candidats: candidats ?? this.candidats,
      moniteurs: moniteurs ?? this.moniteurs,
      previousStatusById: previousStatusById ?? this.previousStatusById,
    );
  }
}

class SeanceCubit extends Cubit<SeanceState> {
  final SeanceService _seanceService;
  final UserService _userService;

  SeanceCubit(this._seanceService, this._userService) : super(SeanceState.initial());

  Future<void> loadInitial() async {
    await Future.wait([loadParticipants(), loadAll()]);
  }

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _seanceService.getAllSeances();
      final enriched = _enrichSeances(items);
      emit(state.copyWith(seances: enriched, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadParticipants() async {
    try {
      final all = await _userService.fetchAllUsers(role: '', page: 1);
      final candidats = all.users.where((u) => _isCandidat(u.role)).toList();
      final moniteurs = all.users.where((u) => _isPersonnel(u.role)).toList();
      emit(state.copyWith(candidats: candidats, moniteurs: moniteurs));
      if (state.seances.isNotEmpty) {
        emit(state.copyWith(seances: _enrichSeances(state.seances)));
      }
    } catch (e) {
      try {
        final candidats = await _userService.fetchAllUsers(role: 'candidat', page: 1);
        final moniteurs = await _userService.fetchAllUsers(role: 'moniteur', page: 1);
        emit(state.copyWith(candidats: candidats.users, moniteurs: moniteurs.users));
        if (state.seances.isNotEmpty) {
          emit(state.copyWith(seances: _enrichSeances(state.seances)));
        }
      } catch (inner) {
        emit(state.copyWith(error: inner.toString()));
      }
    }
  }

  Future<void> loadByDate(DateTime date) async {
    emit(state.copyWith(isLoading: true, error: null, selectedDate: date));
    try {
      final items = await _seanceService.getSeancesByDate(date);
      final enriched = _enrichSeances(items);
      emit(state.copyWith(seances: enriched, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<bool> addSeance(SeanceDraft draft) async {
    if (_hasConflict(draft)) {
      emit(state.copyWith(error: 'Conflit: ce moniteur est déjà réservé à ce créneau.'));
      return false;
    }
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      final created = await _seanceService.addSeance(draft);
      final enrichedCreated = _enrichSeances([created]).first;
      final updated = [enrichedCreated, ...state.seances]..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      emit(state.copyWith(seances: updated, isSubmitting: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }

  Future<void> cancelSeance(Seance seance) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      final isAnnule = seance.statut.toLowerCase().contains('ann');
      final previous = state.previousStatusById[seance.id] ?? _computeAutomaticStatus(seance);
      final nextStatus = isAnnule ? _normalizeStatusForBackend(previous) : 'annule';
      final updated = await _seanceService.updateStatus(seance.id, nextStatus);
      final enriched = _enrichSeances([updated]).first;
      final list = state.seances.map((s) => s.id == seance.id ? enriched : s).toList();
      final updatedMap = Map<String, String>.from(state.previousStatusById);
      if (!isAnnule) {
        updatedMap[seance.id] = seance.statut;
      } else {
        updatedMap.remove(seance.id);
      }
      emit(state.copyWith(seances: list, isSubmitting: false, previousStatusById: updatedMap));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> updateSeance(Seance seance) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      final updated = await _seanceService.updateSeance(seance);
      final enriched = _enrichSeances([updated]).first;
      final list = state.seances.map((s) => s.id == seance.id ? enriched : s).toList();
      emit(state.copyWith(seances: list, isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> deleteSeance(Seance seance) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _seanceService.deleteSeance(seance.id);
      final list = state.seances.where((s) => s.id != seance.id).toList();
      emit(state.copyWith(seances: list, isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  bool _hasConflict(SeanceDraft draft) {
    final draftMinutes = _toMinutes(draft.heure);
    return state.seances.any((s) {
      if (s.personnelId != draft.personnelId) return false;
      if (!_isSameDate(s.date, draft.date)) return false;
      return _toMinutes(s.heure) == draftMinutes;
    });
  }

  static int _toMinutes(String time) {
    final parts = time.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return h * 60 + m;
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _isCandidat(String role) {
    final r = role.toLowerCase();
    return r.contains('candidat');
  }

  static bool _isPersonnel(String role) {
    final r = role.toLowerCase();
    return r.contains('moniteur') || r.contains('personnel') || r.contains('admin');
  }

  static String _normalizeStatusForBackend(String status) {
    final s = status.toLowerCase();
    if (s.contains('term')) return 'termine';
    if (s.contains('cours')) return 'en_cours';
    if (s.contains('ann')) return 'annule';
    return 'a_venir';
  }

  static String _computeAutomaticStatus(Seance seance) {
    final start = seance.startDateTime;
    final end = start.add(Duration(minutes: _durationMinutes(seance.duree)));
    final now = DateTime.now();
    if (now.isBefore(start)) return 'a_venir';
    if (now.isBefore(end)) return 'en_cours';
    return 'termine';
  }

  static int _durationMinutes(String? value) {
    if (value == null || value.trim().isEmpty) return 60;
    final text = value.toLowerCase().replaceAll(',', '.');
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    if (match == null) return 60;
    final hours = double.tryParse(match.group(1) ?? '');
    if (hours == null) return 60;
    return (hours * 60).round();
  }

  List<Seance> _enrichSeances(List<Seance> items) {
    return items.map((s) {
      final candidat = state.candidats.firstWhere(
        (u) => u.candidatId != null && u.candidatId == s.candidatId,
        orElse: () => const AdminUser(
          id: '',
          nom: '',
          prenom: '',
          email: '',
          login: '',
          telephone: '',
          role: '',
          status: '',
        ),
      );
      final moniteur = state.moniteurs.firstWhere(
        (u) => u.personnelId != null && u.personnelId == s.personnelId,
        orElse: () => const AdminUser(
          id: '',
          nom: '',
          prenom: '',
          email: '',
          login: '',
          telephone: '',
          role: '',
          status: '',
        ),
      );
      return Seance(
        id: s.id,
        date: s.date,
        heure: s.heure,
        type: s.type,
        candidatId: s.candidatId,
        personnelId: s.personnelId,
        statut: s.statut,
        duree: s.duree,
        remarque: s.remarque,
        candidatName: s.candidatName ?? (candidat.fullName.isNotEmpty ? candidat.fullName : null),
        moniteurName: s.moniteurName ?? (moniteur.fullName.isNotEmpty ? moniteur.fullName : null),
        candidatAvatar: s.candidatAvatar,
        moniteurAvatar: s.moniteurAvatar,
        candidatEmail: s.candidatEmail ?? (candidat.email.isNotEmpty ? candidat.email : null),
        moniteurEmail: s.moniteurEmail ?? (moniteur.email.isNotEmpty ? moniteur.email : null),
      );
    }).toList();
  }
}
