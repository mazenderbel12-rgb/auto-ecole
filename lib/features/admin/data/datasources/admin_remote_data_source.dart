import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class AdminRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> getDashboardStats() async {
    final candidats = await _getListData('/candidats');
    final seances = await _getListData('/seances');
    final paiements = await _getListData('/paiements');

    double totalRevenu = 0;
    for (var p in paiements) {
      final montant = (p is Map)
          ? p['Montant'] ?? p['montant'] ?? p['amount']
          : null;
      totalRevenu += double.tryParse(montant?.toString() ?? '0') ?? 0;
    }

    return {
      'candidats': candidats.length.toString(),
      'revenu': '${totalRevenu.toStringAsFixed(0)} DT',
      'seances': seances.length.toString(),
      'reussite': '85%',
      'activities': _buildRecentActivities(
        candidats: candidats,
        seances: seances,
        paiements: paiements,
      ),
    };
  }

  Future<List<dynamic>> getUsers(String role) async {
    return await _getListData('/utilisateurs');
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _dio.delete('/utilisateurs/$userId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Utilisateur introuvable');
      }
      rethrow;
    }
  }

  // Admin operations
  Future<void> createCandidat(Map<String, dynamic> data) async {
    await _postData('/candidats', data);
  }

  Future<void> createMoniteur(Map<String, dynamic> data) async {
    await _postData('/moniteurs', data);
  }

  Future<void> createSeance(Map<String, dynamic> data) async {
    await _postData('/seances', data);
  }

  Future<void> createPaiement(Map<String, dynamic> data) async {
    await _postData('/paiements', data);
  }

  Future<List<dynamic>> getPersonnel() async {
    return await _getListData('/personnel');
  }

  Future<List<dynamic>> getVehicules() async {
    return await _getListData('/vehicules');
  }

  Future<List<dynamic>> _getListData(String path) async {
    try {
      final response = await _dio.get(path);
      return _extractList(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> _postData(String path, Map<String, dynamic> data) async {
    try {
      await _dio.post(path, data: data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Point de terminaison introuvable pour $path');
      }
      rethrow;
    }
  }

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final possible = data['data'] ?? data['results'] ?? data['items'];
      if (possible is List) return possible;
    }
    return [];
  }

  List<Map<String, String>> _buildRecentActivities({
    required List candidats,
    required List seances,
    required List paiements,
  }) {
    final activities = <Map<String, String>>[];

    for (final candidat in candidats.take(2)) {
      if (candidat is Map) {
        final prenom = candidat['Prenom']?.toString() ?? '';
        final nom = candidat['Nom']?.toString() ?? '';
        activities.add({
          'text': 'Nouveau candidat: ${_fullName(prenom, nom)}',
          'time': _formatTime(_extractDate(candidat)),
        });
      }
    }

    for (final seance in seances.take(2)) {
      if (seance is Map) {
        final type = seance['Type_Seance']?.toString() ?? seance['type']?.toString();
        activities.add({
          'text': type == null ? 'Seance planifiee' : 'Seance: $type',
          'time': _formatTime(_extractDate(seance)),
        });
      }
    }

    for (final paiement in paiements.take(2)) {
      if (paiement is Map) {
        final montant = paiement['Montant'] ?? paiement['montant'] ?? paiement['amount'];
        final value = double.tryParse(montant?.toString() ?? '0') ?? 0;
        activities.add({
          'text': 'Paiement: ${value.toStringAsFixed(0)} DT',
          'time': _formatTime(_extractDate(paiement)),
        });
      }
    }

    return activities.take(6).toList();
  }

  String _fullName(String prenom, String nom) {
    final full = ('$prenom $nom').trim();
    return full.isEmpty ? 'Sans nom' : full;
  }

  DateTime? _extractDate(Map item) {
    const keys = [
      'created_at',
      'updated_at',
      'date',
      'Date_Seance',
      'date_seance',
      'Date_Paiement',
      'date_paiement',
    ];
    for (final key in keys) {
      final value = item[key];
      if (value == null) continue;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'Recent';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'A l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
