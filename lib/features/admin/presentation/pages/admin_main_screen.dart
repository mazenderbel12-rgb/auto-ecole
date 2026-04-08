import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import 'users_management_page.dart';
import 'profile_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../widgets/admin_drawer.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const DashboardPage(),
    const UsersManagementPage(),
    const ChatListPage(isSubPage: true), 
    const ProfilePage(), 
  ];

  final List<String> _titles = [
    'TABLEAU DE BORD',
    'UTILISATEURS',
    'MESSAGES',
    'PROFIL ADMIN',
  ];

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF1E293B);
    const Color accentOrange = Color(0xFFEB984E);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AdminDrawer(), // Left side drawer for navigation
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu_rounded, color: darkNavy, size: 28),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _titles[_currentIndex],
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: darkNavy,
                letterSpacing: 1,
              ),
            ),
            if (_currentIndex == 0)
              Text(
                'Élite Conduite',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentOrange,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: darkNavy, size: 22),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, -10)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: accentOrange,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: GoogleFonts.lexend(fontWeight: FontWeight.w500, fontSize: 10),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'ACCUEIL'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'USERS'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'MESSAGES'),
            BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: 'COMPTE'),
          ],
        ),
      ),
    );
  }
}
