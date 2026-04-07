import 'package:flutter/material.dart';
import 'login_page.dart';
import 'admin_register_page.dart';
import '../widgets/premium_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: darkNavy,
      body: Stack(
        children: [
          // Background Gradient/Image Decoration
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  darkNavy,
                  darkNavy.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 64),
                
                // Logo Section (Floating Premium)
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        'assets/images/Logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Title Section
                Text(
                  'Auto École',
                  style: GoogleFonts.lexend(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'Élite Conduite',
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEB984E),
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Gérez votre formation, vos séances et vos examens en toute élégance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Panel
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // Action Buttons (NO GRID AS REQUESTED)
                      ActionButton(
                        text: 'Se Connecter',
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                      ),

                      const SizedBox(height: 20),

                      ActionButton(
                        text: 'Créer Compte Admin',
                        isSecondary: true,
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterPage()));
                        },
                      ),

                      const SizedBox(height: 24),
                      
                      Text(
                        'Plateforme sécurisée · Données protégées',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
