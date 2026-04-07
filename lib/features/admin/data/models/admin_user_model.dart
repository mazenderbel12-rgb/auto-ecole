import 'package:equatable/equatable.dart';

class AdminUser extends Equatable {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String login;
  final String telephone;
  final String role;
  final String status;
  final String? cin;
  final String? dateNaissance;
  final String? adresse;
  
  // Specific to Candidat
  final String? dateInscription;
  final int? heureCode;
  final int? heureConduite;
  final int? heureParking;
  final bool? hasPermis;
  final bool? codeValide;
  final bool? conduiteValide;
  final bool? parkingValide;
  final String? niveau;
  
  // Progress/Relations
  final String? personnelCode;
  final List<String> assignedCandidateIds;

  const AdminUser({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.login,
    required this.telephone,
    required this.role,
    required this.status,
    this.cin,
    this.dateNaissance,
    this.adresse,
    this.dateInscription,
    this.heureCode,
    this.heureConduite,
    this.heureParking,
    this.hasPermis,
    this.codeValide,
    this.conduiteValide,
    this.parkingValide,
    this.niveau,
    this.personnelCode,
    this.assignedCandidateIds = const [],
  });

  String get fullName => ('$prenom $nom').trim();
  String get initials => (prenom.isNotEmpty && nom.isNotEmpty) ? '${prenom[0]}${nom[0]}'.toUpperCase() : '?';

  static String? _formatDate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    if (str.length >= 10) return str.substring(0, 10);
    return str;
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : json;
    
    // Role detection
    final roleData = user['role'] ?? user['Role'];
    String extractedRole = 'candidat';
    if (user['role_name'] != null) {
      extractedRole = user['role_name'].toString().toLowerCase();
    } else if (roleData != null && roleData is Map) {
      extractedRole = (roleData['NomRole'] ?? roleData['name'] ?? roleData['Nom']).toString().toLowerCase();
    }

    // Nested data extraction
    final candidat = user['candidat'] ?? user['Candidat'];
    final personnel = user['personnel'] ?? user['Personnel'];

    return AdminUser(
      id: (user['Id_Utilisateur'] ?? user['id'] ?? '').toString(),
      nom: user['Nom']?.toString() ?? user['nom']?.toString() ?? '',
      prenom: user['Prenom']?.toString() ?? user['prenom']?.toString() ?? '',
      email: user['Email']?.toString() ?? user['email']?.toString() ?? '',
      login: user['Login']?.toString() ?? user['login']?.toString() ?? '',
      telephone: user['Telephone']?.toString() ?? user['telephone']?.toString() ?? '',
      role: extractedRole,
      status: user['status']?.toString() ?? user['etat']?.toString() ?? 'Actif',
      cin: (candidat?['CIN'] ?? personnel?['CIN'])?.toString(),
      dateNaissance: _formatDate(user['DateDeNaissance'] ?? user['date_de_naissance'] ?? user['DateNaissance']),
      adresse: (candidat?['Adresse'] ?? personnel?['Adresse'])?.toString(),
      
      // Candidat Specifics
      dateInscription: _formatDate(candidat?['DateInscription']),
      heureCode: _toInt(candidat?['HeureCode']),
      heureConduite: _toInt(candidat?['HeureConduite']),
      heureParking: _toInt(candidat?['HeureParking']),
      hasPermis: _toBool(candidat?['Permis']),
      codeValide: _toBool(candidat?['CodeValide']),
      conduiteValide: _toBool(candidat?['ConduiteValide']),
      parkingValide: _toBool(candidat?['ParkingValide']),
      niveau: candidat?['Niveau']?.toString(),
      
      personnelCode: (user['Code_Personnel'] ?? personnel?['Code_Personnel'])?.toString(),
      assignedCandidateIds: _extractIds(user['assigned_candidates']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value.toString().toLowerCase() == 'true' || value.toString() == '1';
  }

  static List<String> _extractIds(dynamic data) {
    if (data is List) {
      return data.map((item) => (item is Map ? (item['id'] ?? item['Id_Utilisateur']) : item).toString()).toList();
    }
    return const [];
  }

  AdminUser copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? login,
    String? telephone,
    String? role,
    String? status,
    String? cin,
    String? dateNaissance,
    String? adresse,
    String? dateInscription,
    int? heureCode,
    int? heureConduite,
    int? heureParking,
    bool? hasPermis,
    bool? codeValide,
    bool? conduiteValide,
    bool? parkingValide,
    String? niveau,
  }) {
    return AdminUser(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      login: login ?? this.login,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      status: status ?? this.status,
      cin: cin ?? this.cin,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      adresse: adresse ?? this.adresse,
      dateInscription: dateInscription ?? this.dateInscription,
      heureCode: heureCode ?? this.heureCode,
      heureConduite: heureConduite ?? this.heureConduite,
      heureParking: heureParking ?? this.heureParking,
      hasPermis: hasPermis ?? this.hasPermis,
      codeValide: codeValide ?? this.codeValide,
      conduiteValide: conduiteValide ?? this.conduiteValide,
      parkingValide: parkingValide ?? this.parkingValide,
      niveau: niveau ?? this.niveau,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Nom': nom,
      'Prenom': prenom,
      'Email': email,
      'Login': login,
      'Telephone': telephone,
      'DateDeNaissance': dateNaissance,
      'CIN': cin,
      'Adresse': adresse,
      'HeureCode': heureCode,
      'HeureConduite': heureConduite,
      'HeureParking': heureParking,
      'Permis': (hasPermis ?? false) ? 1 : 0,
      'CodeValide': (codeValide ?? false) ? 1 : 0,
      'ConduiteValide': (conduiteValide ?? false) ? 1 : 0,
      'ParkingValide': (parkingValide ?? false) ? 1 : 0,
      'Niveau': niveau,
    };
  }

  @override
  List<Object?> get props => [id, nom, prenom, email, login, telephone, role, status];
}
