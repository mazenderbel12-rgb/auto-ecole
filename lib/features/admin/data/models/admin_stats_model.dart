import 'package:equatable/equatable.dart';

class AdminStatsModel extends Equatable {
  final String candidats;
  final String revenu;
  final String seances;
  final String reussite;
  final List<AdminActivity> activities;

  const AdminStatsModel({
    required this.candidats,
    required this.revenu,
    required this.seances,
    required this.reussite,
    required this.activities,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      candidats: json['candidats']?.toString() ?? '0',
      revenu: json['revenu']?.toString() ?? '0 DT',
      seances: json['seances']?.toString() ?? '0',
      reussite: json['reussite']?.toString() ?? '0%',
      activities: ((json['activities'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => AdminActivity.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candidats': candidats,
      'revenu': revenu,
      'seances': seances,
      'reussite': reussite,
      'activities': activities.map((item) => item.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [candidats, revenu, seances, reussite, activities];
}

class AdminActivity extends Equatable {
  final String text;
  final String time;

  const AdminActivity({
    required this.text,
    required this.time,
  });

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    return AdminActivity(
      text: json['text']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'text': text, 'time': time};

  @override
  List<Object?> get props => [text, time];
}
