import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:application/features/auth/presentation/view_models/auth_cubit.dart';
import '../pages/users_management_page.dart';
import '../pages/gestion_utilisateurs_page.dart';

class AdminDrawer extends StatelessWidget {
  final Function(int)? onNavigate;
  const AdminDrawer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF1E293B);
    const Color accentOrange = Color(0xFFEB984E);

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Elegant Header
          Container(
            padding: const EdgeInsets.fromLTRB(28, 64, 28, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkNavy, Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(40)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60, padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auto École', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text('Élite Conduite', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold, color: accentOrange, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildDrawerItem(Icons.dashboard_rounded, 'Tableau de Bord', () {}),
                _buildDrawerItem(Icons.people_alt_rounded, 'Gestion Utilisateurs', () {
                  Navigator.pop(context);
                  if (onNavigate != null) {
                    onNavigate!(1);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GestionUtilisateursPage()),
                    );
                  }
                }),
                _buildDrawerItem(Icons.calendar_today_rounded, 'Planning & Séances', () {}),
                _buildDrawerItem(Icons.assignment_rounded, 'Examens', () {}),
                _buildDrawerItem(Icons.directions_car_rounded, 'Véhicules', () {}),
                _buildDrawerItem(Icons.payments_rounded, 'Paiements', () {}),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFFF1F5F9), thickness: 2),
                ),
                _buildDrawerItem(Icons.settings_suggest_rounded, 'Paramètres Système', () {}),
                _buildDrawerItem(Icons.logout_rounded, 'Déconnexion', () {
                  context.read<AuthCubit>().logout();
                }, isDestructive: true),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text('v1.0.0 PREMIUM', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFCBD5E1), letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    const Color darkNavy = Color(0xFF1E293B);
    final color = isDestructive ? const Color(0xFFEF4444) : darkNavy;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDestructive ? const Color(0xFFFEF2F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: color, size: 22),
        title: Text(title, style: GoogleFonts.lexend(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
      ),
    );
  }
}
