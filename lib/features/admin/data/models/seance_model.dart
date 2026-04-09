class Seance {
  final String id;
  final DateTime date;
  final String heure;
  final String type;
  final String candidatId;
  final String personnelId;
  final String statut;
  final String? duree;
  final String? remarque;
  final String? candidatName;
  final String? moniteurName;
  final String? candidatAvatar;
  final String? moniteurAvatar;
  final String? candidatEmail;
  final String? moniteurEmail;

  const Seance({
    required this.id,
    required this.date,
    required this.heure,
    required this.type,
    required this.candidatId,
    required this.personnelId,
    required this.statut,
    this.duree,
    this.remarque,
    this.candidatName,
    this.moniteurName,
    this.candidatAvatar,
    this.moniteurAvatar,
    this.candidatEmail,
    this.moniteurEmail,
  });

  factory Seance.fromJson(Map<String, dynamic> json) {
    final candidat = json['candidat'] as Map<String, dynamic>?;
    final moniteur = json['moniteur'] as Map<String, dynamic>?;
    return Seance(
      id: (json['id'] ?? json['Id_Seance'] ?? '').toString(),
      date: _parseDate(json['DateSeance'] ?? json['date'] ?? json['Date'] ?? json['DateSeance']),
      heure: _parseTime(json['HeureSeance'] ?? json['heure'] ?? json['Heure'] ?? json['HeureSeance'] ?? '09:00:00'),
      type: (json['TypeSeance'] ?? json['type'] ?? json['Type'] ?? 'conduite').toString().toLowerCase(),
      candidatId: (json['Id_Candidat'] ?? json['candidat_id'] ?? candidat?['Id_Candidat'] ?? '').toString(),
      personnelId: (json['Id_Personnel'] ?? json['personnel_id'] ?? moniteur?['Id_Personnel'] ?? '').toString(),
      statut: (json['Statut'] ?? json['statut'] ?? 'a_venir').toString().toLowerCase(),
      duree: (json['Duree'] ?? json['duree'])?.toString(),
      remarque: (json['Remarque'] ?? json['remarque'])?.toString(),
      candidatName: _fullName(candidat?['Prenom'], candidat?['Nom']) ?? json['candidat_name']?.toString(),
      moniteurName: _fullName(moniteur?['Prenom'], moniteur?['Nom']) ?? json['moniteur_name']?.toString(),
      candidatAvatar: candidat?['Avatar']?.toString(),
      moniteurAvatar: moniteur?['Avatar']?.toString(),
      candidatEmail: candidat?['Email']?.toString() ?? json['candidat_email']?.toString(),
      moniteurEmail: moniteur?['Email']?.toString() ?? json['moniteur_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DateSeance': _formatDate(date),
      'HeureSeance': _formatTime(heure),
      'TypeSeance': type,
      'Id_Candidat': candidatId,
      'Id_Personnel': personnelId,
      if (duree != null) 'Duree': duree,
      if (remarque != null) 'Remarque': remarque,
    };
  }

  DateTime get startDateTime {
    final parts = heure.split(':');
    final h = int.tryParse(parts.first) ?? 9;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }

  DateTime get endDateTime => startDateTime.add(Duration(minutes: _durationMinutes(duree)));

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    final parsed = DateTime.tryParse(value.toString());
    return parsed ?? DateTime.now();
  }

  static String _parseTime(dynamic value) {
    if (value == null) return '09:00';
    final str = value.toString();
    if (str.contains('T')) {
      final parts = str.split('T');
      if (parts.length > 1) return parts[1].substring(0, 5);
    }
    if (str.length >= 5) return str.substring(0, 5);
    return str;
  }

  static String _formatTime(String time) {
    final parts = time.split(':');
    final hh = (parts.isNotEmpty ? parts[0] : '09').padLeft(2, '0');
    final mm = (parts.length > 1 ? parts[1] : '00').padLeft(2, '0');
    return '$hh:$mm:00';
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

  static String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  static String? _fullName(dynamic prenom, dynamic nom) {
    final p = prenom?.toString();
    final n = nom?.toString();
    if ((p ?? '').isEmpty && (n ?? '').isEmpty) return null;
    return '${p ?? ''} ${n ?? ''}'.trim();
  }
}

class SeanceDraft {
  final DateTime date;
  final String heure;
  final String type;
  final String candidatId;
  final String personnelId;
  final String? duree;
  final String? remarque;

  const SeanceDraft({
    required this.date,
    required this.heure,
    required this.type,
    required this.candidatId,
    required this.personnelId,
    this.duree,
    this.remarque,
  });
}
