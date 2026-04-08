import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/models/admin_user_model.dart';
import '../view_models/users_management_cubit.dart';
import 'user_profile_page.dart';

class GestionUtilisateursPage extends StatefulWidget {
  const GestionUtilisateursPage({super.key});

  @override
  State<GestionUtilisateursPage> createState() => _GestionUtilisateursPageState();
}

class _GestionUtilisateursPageState extends State<GestionUtilisateursPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<UserManagementCubit>()..loadInitial(''),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FB),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF1E2A3B),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ADMINISTRATION', style: GoogleFonts.lexend(fontSize: 10, color: Colors.white70, letterSpacing: 1)),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(text: 'Gestion ', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                                        TextSpan(text: 'Utilisateurs', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: const Color(0xFFEB984E))),
                                      ]
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, color: Colors.white),
                              onPressed: () => _openUserForm(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildTopSearchBar(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildRoleChips(context),
                  const SizedBox(height: 12),
                  _buildCountRow(context),
                  const SizedBox(height: 8),
                  Expanded(child: _buildUserList()),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildTopSearchBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            SizedBox(
              width: constraints.maxWidth - 56, // Total width minus the filter button and spacing
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF253247),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => context.read<UserManagementCubit>().updateQuery(value),
                        style: GoogleFonts.lexend(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un utilisateur...',
                          hintStyle: GoogleFonts.lexend(color: Colors.white54, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF253247),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white70, size: 20),
            ),
          ],
        );
      }
    );
  }

  Widget _buildStatsRow() {
    return BlocBuilder<UserManagementCubit, UserManagementState>(
      builder: (context, state) {
        final total = state.users.length;
        final active = state.users.where((u) => u.status.toLowerCase().contains('actif')).length;
        final pending = state.users.where((u) => u.status.toLowerCase().contains('attente')).length;
        final candidats = state.users.where((u) => u.role.toLowerCase() == 'candidat').length;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                _StatCard(label: 'Total', value: '$total', color: const Color(0xFF2E86C1)),
                const SizedBox(width: 10),
                _StatCard(label: 'Actifs', value: '$active', color: const Color(0xFF22C55E)),
                const SizedBox(width: 10),
                _StatCard(label: 'En attente', value: '$pending', color: const Color(0xFFEB984E)),
                const SizedBox(width: 10),
                _StatCard(label: 'Candidats', value: '$candidats', color: const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleChips(BuildContext context) {
    return BlocBuilder<UserManagementCubit, UserManagementState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
              ]
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: _RoleChip(label: 'Tous', selected: state.role == '', onTap: () {
                  _searchController.clear();
                  context.read<UserManagementCubit>().loadInitial('');
                })),
                Expanded(flex: 1, child: _RoleChip(label: 'Candidats', selected: state.role == 'candidat', onTap: () {
                  _searchController.clear();
                  context.read<UserManagementCubit>().loadInitial('candidat');
                })),
                Expanded(flex: 1, child: _RoleChip(label: 'Moniteurs', selected: state.role == 'moniteur', onTap: () {
                  _searchController.clear();
                  context.read<UserManagementCubit>().loadInitial('moniteur');
                })),
                Expanded(flex: 1, child: _RoleChip(label: 'Personnel', selected: state.role == 'personnel', onTap: () {
                  _searchController.clear();
                  context.read<UserManagementCubit>().loadInitial('personnel');
                })),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildCountRow(BuildContext context) {
    return BlocBuilder<UserManagementCubit, UserManagementState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.filteredUsers.length} comptes',
                style: GoogleFonts.lexend(fontSize: 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                ),
                onPressed: () => _openUserForm(context),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: Text('Créer un compte', style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(text, style: GoogleFonts.lexend(color: const Color(0xFF94A3B8))),
      ),
    );
  }

  Widget _buildUserList() {
    return BlocBuilder<UserManagementCubit, UserManagementState>(
      builder: (context, state) {
        if (state.isLoading && state.users.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF2E86C1))),
          );
        }

        final users = state.filteredUsers;
        if (users.isEmpty) {
          return _buildEmptyState('Aucun utilisateur trouvé');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: users.length,
          itemBuilder: (context, index) => _UserCard(
            user: users[index],
            onTap: () => _openProfile(context, users[index]),
          ),
        );
      },
    );
  }

  void _openProfile(BuildContext context, AdminUser user) {
    final cubit = context.read<UserManagementCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: UserProfilePage(userId: user.id),
        ),
      ),
    );
  }

  void _openUserForm(BuildContext context) {
    final cubit = context.read<UserManagementCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _UserFormSheet(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.lexend(fontSize: 11, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({required this.label, this.selected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Generate initials safely
    String initals = "?";
    if (user.prenom.isNotEmpty && user.nom.isNotEmpty) {
      initals = "${user.prenom[0]}${user.nom[0]}".toUpperCase();
    } else if (user.fullName.isNotEmpty) {
      initals = user.fullName[0].toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              initals,
              style: GoogleFonts.lexend(fontSize: 18, color: const Color(0xFF475569), fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName : "Utilisateur sans nom", 
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusBadge(status: user.status),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.role, 
                    style: GoogleFonts.lexend(fontSize: 11, color: const Color(0xFF0EA5E9), fontWeight: FontWeight.w600)
                  ),
                ),
                const SizedBox(height: 4),
                Text(user.email, style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onTap,
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2E86C1)),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Quick dialog for deletion optionally
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status.toLowerCase().contains('attente');
    final isActive = status.toLowerCase().contains('actif');
    
    Color textColor = const Color(0xFF64748B);
    Color dotColor = const Color(0xFF94A3B8);

    if (isActive) {
      textColor = const Color(0xFF16A34A);
      dotColor = const Color(0xFF22C55E);
    } else if (isPending) {
      textColor = const Color(0xFFD97706);
      dotColor = const Color(0xFFF59E0B);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status,
          style: GoogleFonts.lexend(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _UserFormSheet extends StatefulWidget {
  const _UserFormSheet();

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _loginController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _permisController = TextEditingController();
  String _role = 'candidat';

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _loginController.dispose();
    _telephoneController.dispose();
    _permisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nouveau Compte', style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildTextField('Nom', _nomController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Prénom', _prenomController)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField('Login', _loginController),
              const SizedBox(height: 12),
              _buildTextField('Téléphone', _telephoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildRoleDropdown(),
              if (_role == 'candidat') ...[
                const SizedBox(height: 12),
                _buildTextField('Permis (Laissez vide si aucun)', _permisController),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final payload = AdminUser(
                      id: '',
                      nom: _nomController.text.trim(),
                      prenom: _prenomController.text.trim(),
                      email: _emailController.text.trim(),
                      login: _loginController.text.trim(),
                      telephone: _telephoneController.text.trim(),
                      role: _role,
                      status: 'Actif',
                      hasPermis: _role == 'candidat' ? _permisController.text.trim().isNotEmpty : null,
                      personnelCode: null,
                      assignedCandidateIds: const [],
                    );
                    await context.read<UserManagementCubit>().createUser(payload);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Créer le compte', style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lexend(color: const Color(0xFF64748B), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _role,
      items: const [
        DropdownMenuItem(value: 'candidat', child: Text('Candidat')),
        DropdownMenuItem(value: 'moniteur', child: Text('Moniteur')),
        DropdownMenuItem(value: 'personnel', child: Text('Personnel')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _role = value);
      },
      decoration: InputDecoration(
        labelText: 'Rôle',
        labelStyle: GoogleFonts.lexend(color: const Color(0xFF64748B), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
