import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/admin_user_model.dart';
import '../view_models/users_management_cubit.dart';

class EditUserProfilePage extends StatefulWidget {
  final AdminUser user;
  const EditUserProfilePage({super.key, required this.user});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telController;
  late TextEditingController _loginController;
  late TextEditingController _birthController;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nomController = TextEditingController(text: u.nom);
    _prenomController = TextEditingController(text: u.prenom);
    _emailController = TextEditingController(text: u.email);
    _telController = TextEditingController(text: u.telephone);
    _loginController = TextEditingController(text: u.login);
    _birthController = TextEditingController(text: u.dateNaissance ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _loginController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Modifier Profil', style: GoogleFonts.lexend(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E2F45),
      ),
      body: BlocConsumer<UserManagementCubit, UserManagementState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: Colors.red));
          } else if (!state.isLoading && state.error == null) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: Color(0xFF16A34A)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('INFORMATIONS PERSONNELLES'),
                  const SizedBox(height: 20),
                  _buildField('Nom', _nomController, Icons.person_outline),
                  _buildField('Prénom', _prenomController, Icons.person_outline),
                  _buildField('Email', _emailController, Icons.email_outlined),
                  _buildField('Téléphone', _telController, Icons.phone_outlined),
                  _buildField('Date de Naissance (AAAA-MM-JJ)', _birthController, Icons.calendar_today_outlined),
                  _buildField('Login', _loginController, Icons.key_outlined),
                  
                  const SizedBox(height: 48),
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF1E2F45)))
                  else
                    _buildSaveButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF64748B)),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1E2F45)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: const Color(0xFF64748B)));
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E2F45),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text('Enregistrer les modifications', style: GoogleFonts.lexend(fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // Create update object preserving existing training data, CIN and Adresse
      final updated = widget.user.copyWith(
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        telephone: _telController.text,
        login: _loginController.text,
        dateNaissance: _birthController.text,
      );
      context.read<UserManagementCubit>().updateUser(updated);
    }
  }
}
