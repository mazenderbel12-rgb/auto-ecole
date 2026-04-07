import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String roleName;
  final String? token;

  const UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.roleName,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final user = json['user'] ?? json;
    // Laravel ->load('role') uses the lowercase relationship name as the key
    final roleData = user['role'] ?? user['Role'];
    
    return UserModel(
      id: user['Id_Utilisateur']?.toString() ?? '',
      nom: user['Nom'] ?? '',
      prenom: user['Prenom'] ?? '',
      email: user['Email'] ?? '',
      telephone: user['Telephone'],
      roleName: json['role_name'] ?? roleData?['NomRole'] ?? 'candidat',
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id_Utilisateur': id,
      'Nom': nom,
      'Prenom': prenom,
      'Email': email,
      'Telephone': telephone,
      'token': token,
    };
  }

  @override
  List<Object?> get props => [id, nom, prenom, email, telephone, roleName, token];
}
