import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/architecture/base_state.dart' as base;
import '../../../auth/presentation/view_models/auth_cubit.dart';
import '../../../auth/data/models/user_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF1E293B);
    const Color accentOrange = Color(0xFFEB984E);

    return BlocBuilder<AuthCubit, base.BaseState<UserModel>>(
      builder: (context, state) {
        if (state is! base.Success<UserModel>) return const Center(child: CircularProgressIndicator(color: accentOrange));
        final user = state.data;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 40, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(color: darkNavy, shape: BoxShape.circle, boxShadow: [BoxShadow(color: darkNavy.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                          child: Center(child: Text('${user.nom[0]}${user.prenom[0]}', style: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white))),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: accentOrange, shape: BoxShape.circle),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('${user.nom} ${user.prenom}', style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.w900, color: darkNavy)),
                    const SizedBox(height: 4),
                    Text(user.email, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8))),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: accentOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('ADMINISTRATEUR', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.bold, color: accentOrange, letterSpacing: 1)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // Settings Groups
              _buildSettingsGroup(context, 'PARAMÈTRES DU COMPTE', [
                _buildItem(Icons.person_outline_rounded, 'Informations Personnelles'),
                _buildItem(Icons.lock_outline_rounded, 'Sécurité & Mot de passe'),
                _buildItem(Icons.notifications_none_rounded, 'Notifications Push'),
              ]),

              const SizedBox(height: 24),

              _buildSettingsGroup(context, 'SYSTÈME', [
                _buildItem(Icons.language_rounded, 'Langue (Français)'),
                _buildItem(Icons.dark_mode_outlined, 'Thème Sombre'),
                _buildItem(Icons.help_outline_rounded, 'Centre d\'Assistance'),
              ]),

              const SizedBox(height: 40),
              
              // Final Action
              _buildLogoutButton(context),
              
              const SizedBox(height: 24),
              Text('v1.0.0 PREMIUM EDITION', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFCBD5E1), letterSpacing: 2)),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF64748B), letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 5))]),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, String title) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF475569), size: 20)),
      title: Text(title, style: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF1E293B))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 14),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.read<AuthCubit>().logout(),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFEF2F2),
        foregroundColor: const Color(0xFFEF4444),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.logout_rounded, size: 20),
          const SizedBox(width: 12),
          Text('SE DÉCONNECTER', style: GoogleFonts.lexend(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        ],
      ),
    );
  }
}
