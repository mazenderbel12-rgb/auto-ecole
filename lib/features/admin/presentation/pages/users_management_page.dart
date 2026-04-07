import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/models/admin_user_model.dart';
import 'user_profile_page.dart';
import '../view_models/users_management_cubit.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<UserManagementCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<UserManagementCubit>()..loadInitial('candidat'),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openUserForm(context),
            backgroundColor: const Color(0xFFEB984E),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Nouveau Compte', style: TextStyle(color: Colors.white)),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 12),
                _buildTabs(context),
                const SizedBox(height: 12),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => context.read<UserManagementCubit>().updateQuery(value),
                  style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un utilisateur...',
                    hintStyle: GoogleFonts.lexend(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1E293B)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune_rounded, color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TabBar(
            indicatorColor: const Color(0xFFEB984E),
            indicatorWeight: 4,
            labelColor: const Color(0xFF1E293B),
            labelStyle: GoogleFonts.lexend(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelColor: const Color(0xFF94A3B8),
            unselectedLabelStyle: GoogleFonts.lexend(fontWeight: FontWeight.w600, fontSize: 13),
            onTap: (index) {
              final roles = ['candidat', 'moniteur', 'personnel'];
              final role = roles[index];
              _searchController.clear();
              context.read<UserManagementCubit>().loadInitial(role);
            },
            tabs: const [Tab(text: 'CANDIDATS'), Tab(text: 'MONITEURS'), Tab(text: 'PERSONNEL')],
          ),
        );
      }
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocConsumer<UserManagementCubit, UserManagementState>(
      listener: (context, state) {
        if (state.error != null) {
          _showSnackBar(context, state.error!, isError: true);
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.users.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E86C1)));
        }

        final users = state.filteredUsers;
        if (users.isEmpty) return _buildEmptyState();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: users.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= users.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF2E86C1))),
              );
            }
            return _buildUserCard(context, users[index]);
          },
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, AdminUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _showUserDetails(context, user),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF2E86C1).withValues(alpha: 0.1),
                child: Text(user.fullName.isNotEmpty ? user.fullName[0] : '?', style: GoogleFonts.lexend(fontWeight: FontWeight.w800, color: const Color(0xFF2E86C1))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text(user.role, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF2E86C1).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(26)), child: const Icon(Icons.people_outline_rounded, size: 40, color: Color(0xFF2E86C1))),
          const SizedBox(height: 16),
          Text('Aucun utilisateur trouvé', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, AdminUser user) {
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _UserFormSheet(),
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final color = isError ? const Color(0xFFF87171) : const Color(0xFF2E86C1);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating));
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
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nouveau Compte',
              style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            _buildTextField('Nom', _nomController),
            const SizedBox(height: 12),
            _buildTextField('Prenom', _prenomController),
            const SizedBox(height: 12),
            _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildTextField('Login', _loginController),
            const SizedBox(height: 12),
            _buildTextField('Telephone', _telephoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildRoleDropdown(),
            if (_role.toLowerCase().contains('candidat')) ...[
              const SizedBox(height: 12),
              _buildTextField('Permis', _permisController),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E86C1)),
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
                    hasPermis: _role.toLowerCase().contains('candidat') 
                        ? (_permisController.text.trim().toLowerCase() == 'oui' || _permisController.text.trim() == '1' || _permisController.text.trim().toLowerCase() == 'true')
                        : null,
                    personnelCode: null,
                    assignedCandidateIds: const [],
                  );
                  await context.read<UserManagementCubit>().createUser(payload);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Ajouter'),
              ),
            ),
          ],
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
      validator: (value) => value == null || value.trim().isEmpty ? 'Champ requis' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _role,
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
        labelText: 'Role',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
