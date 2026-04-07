import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/admin_user_model.dart';
import '../view_models/users_management_cubit.dart';
import 'edit_user_profile_page.dart';

class UserProfilePage extends StatelessWidget {
  final String userId; // Pass ID instead of object
  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementCubit, UserManagementState>(
      builder: (context, state) {
        // Find user by ID in current state to always have fresh data
        final user = state.users.firstWhere(
          (u) => u.id == userId,
          orElse: () => state.filteredUsers.firstWhere(
            (u) => u.id == userId,
            orElse: () => AdminUser(id: userId, nom: '', prenom: '', email: '', login: '', telephone: '', role: 'candidat', status: 'Actif'),
          ),
        );

        final bool isCandidat = user.role.toLowerCase().contains('candidat');

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: BlocListener<UserManagementCubit, UserManagementState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
              }
              // If user no longer exists in state, they were deleted
              final exists = state.users.any((u) => u.id == userId);
              if (!exists && !state.isLoading) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilisateur supprimé'), backgroundColor: Color(0xFFEB984E)));
              }
            },
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, user),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('INFORMATIONS PERSONNELLES'),
                        const SizedBox(height: 16),
                        _buildPersonalInfoCard(user),
                        
                        if (isCandidat) ...[
                          const SizedBox(height: 32),
                          _buildSectionTitle('SUIVI DE FORMATION'),
                          const SizedBox(height: 16),
                          _buildTrainingCard(user),
                          const SizedBox(height: 32),
                          _buildSectionTitle('VALIDATIONS & NIVEAU'),
                          const SizedBox(height: 16),
                          _buildValidationCard(user),
                        ],

                        const SizedBox(height: 40),
                        _buildActionButtons(context, user),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, AdminUser user) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF1E2F45),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Utilisateurs', style: GoogleFonts.lexend(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E2F45), Color(0xFF16202A)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: Center(
                    child: Text(user.initials, style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF5DADE2))),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle, color: Color(0xFF16A34A), size: 10),
                            const SizedBox(width: 8),
                            Text('${user.role.toUpperCase()} • ${user.status}', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: const Color(0xFF64748B)));
  }

  Widget _buildPersonalInfoCard(AdminUser user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _infoItem(Icons.person_outline_rounded, 'Nom & Prénom', user.fullName, const Color(0xFF5DADE2)),
          _divider(),
          _infoItem(Icons.email_outlined, 'Email', user.email, const Color(0xFF5DADE2)),
          _divider(),
          _infoItem(Icons.phone_outlined, 'Téléphone', user.telephone, const Color(0xFFEB984E)),
          _divider(),
          _infoItem(Icons.calendar_today_outlined, 'Date de Naissance', user.dateNaissance ?? '-', const Color(0xFFEB984E)),
          _divider(),
          _infoItem(Icons.key_outlined, 'Login', user.login, const Color(0xFF16A34A)),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(AdminUser user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _infoItem(Icons.assignment_ind_outlined, 'Inscrit le', user.dateInscription ?? '-', const Color(0xFFEB984E)),
          _divider(),
          _infoItem(Icons.timer_outlined, 'Heures Code', '${user.heureCode ?? 0} H', const Color(0xFF5DADE2)),
          _divider(),
          _infoItem(Icons.directions_car_outlined, 'Heures Conduite', '${user.heureConduite ?? 0} H', const Color(0xFF5DADE2)),
          _divider(),
          _infoItem(Icons.local_parking_outlined, 'Heures Parking', '${user.heureParking ?? 0} H', const Color(0xFF16A34A)),
        ],
      ),
    );
  }

  Widget _buildValidationCard(AdminUser user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          _boolItem(Icons.badge_outlined, 'Permis Possédé', user.hasPermis ?? false, const Color(0xFFEB984E)),
          _divider(),
          _boolItem(Icons.fact_check_outlined, 'Code Validé', user.codeValide ?? false, const Color(0xFF5DADE2)),
          _divider(),
          _boolItem(Icons.verified_outlined, 'Conduite Validée', user.conduiteValide ?? false, const Color(0xFF16A34A)),
          _divider(),
          _boolItem(Icons.verified_user_outlined, 'Parking Validé', user.parkingValide ?? false, const Color(0xFF16A34A)),
          _divider(),
          _infoItem(Icons.trending_up, 'Niveau Actuel', user.niveau ?? 'Niveau 1', const Color(0xFFEB984E)),
        ],
      ),
    );
  }

  Widget _boolItem(IconData icon, String label, bool value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(label, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: value ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: Text(value ? 'OUI' : 'NON', style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: value ? const Color(0xFF16A34A) : const Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: const Color(0xFFF1F5F9));

  Widget _buildActionButtons(BuildContext context, AdminUser user) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              final cubit = context.read<UserManagementCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: EditUserProfilePage(user: user),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
            label: Text('Modifier', style: GoogleFonts.lexend(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2F45),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, user),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text('Supprimer', style: GoogleFonts.lexend(fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEB984E),
              side: const BorderSide(color: Color(0xFFEB984E), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, AdminUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer "${user.fullName}" ?', style: GoogleFonts.lexend()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Annuler', style: GoogleFonts.lexend(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserManagementCubit>().deleteUser(user);
            },
            child: Text('Supprimer', style: GoogleFonts.lexend(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
