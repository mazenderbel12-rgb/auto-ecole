import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/models/seance_model.dart';
import '../view_models/seance_cubit.dart';

class EditSeancePage extends StatefulWidget {
  final Seance seance;
  const EditSeancePage({super.key, required this.seance});

  @override
  State<EditSeancePage> createState() => _EditSeancePageState();
}

class _EditSeancePageState extends State<EditSeancePage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late TimeOfDay _time;
  late String _type;
  late TextEditingController _dureeController;
  late TextEditingController _remarqueController;
  AdminUser? _candidat;
  AdminUser? _moniteur;

  @override
  void initState() {
    super.initState();
    final s = widget.seance;
    _date = s.date;
    _time = TimeOfDay(hour: s.startDateTime.hour, minute: s.startDateTime.minute);
    _type = s.type;
    _dureeController = TextEditingController(text: s.duree ?? '');
    _remarqueController = TextEditingController(text: s.remarque ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeanceCubit>().loadInitial();
    });
  }

  @override
  void dispose() {
    _dureeController.dispose();
    _remarqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Modifier Séance', style: GoogleFonts.lexend(color: const Color(0xFF1E293B), fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<SeanceCubit, SeanceState>(
        builder: (context, state) {
          _initParticipants(state);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('INFORMATIONS SÉANCE'),
                  const SizedBox(height: 20),
                  _buildDateField(context),
                  _buildTimeField(context),
                  _buildTypeDropdown(),
                  _buildParticipantField(
                    label: 'Candidat',
                    value: _candidat?.fullName ?? widget.seance.candidatName ?? '',
                    onTap: () async {
                      final user = await _openSelection(context, 'Choisir un candidat', state.candidats);
                      if (user != null) setState(() => _candidat = user);
                    },
                  ),
                  _buildParticipantField(
                    label: 'Moniteur / Personnel',
                    value: _moniteur?.fullName ?? widget.seance.moniteurName ?? '',
                    onTap: () async {
                      final user = await _openSelection(context, 'Choisir un moniteur', state.moniteurs);
                      if (user != null) {
                        setState(() => _moniteur = user);
                        if (_isPersonnelCode(user)) {
                          setState(() => _type = 'code');
                        }
                      }
                    },
                  ),
                  _buildField('Durée (ex: 1, 1.5)', _dureeController, Icons.timer_outlined),
                  _buildField('Remarque', _remarqueController, Icons.notes_outlined, isRequired: false),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _save(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2F45),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('Enregistrer les modifications', style: GoogleFonts.lexend(fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _initParticipants(SeanceState state) {
    _candidat ??= state.candidats.firstWhere(
      (u) => u.candidatId != null && u.candidatId == widget.seance.candidatId,
      orElse: () => _candidat ?? AdminUser(id: '', nom: '', prenom: '', email: '', login: '', telephone: '', role: '', status: ''),
    );
    _moniteur ??= state.moniteurs.firstWhere(
      (u) => u.personnelId != null && u.personnelId == widget.seance.personnelId,
      orElse: () => _moniteur ?? AdminUser(id: '', nom: '', prenom: '', email: '', login: '', telephone: '', role: '', status: ''),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: const Color(0xFF64748B)));
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF64748B)),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1E2F45)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (!isRequired) return null;
          if (value == null || value.trim().isEmpty) return 'Champ requis';
          if (label.startsWith('Durée')) {
            return _validateDuration(value);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildParticipantField({required String label, required String value, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF64748B)),
            prefixIcon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF1E2F45)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          child: Text(value.isEmpty ? 'Sélectionner' : value, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _date,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) setState(() => _date = picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date',
            labelStyle: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF64748B)),
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF1E2F45)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          child: Text(_formatDate(_date), style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: _time);
          if (picked != null) setState(() => _time = picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Heure',
            labelStyle: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF64748B)),
            prefixIcon: const Icon(Icons.access_time_rounded, size: 20, color: Color(0xFF1E2F45)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          child: Text(_time.format(context), style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _type,
        items: const [
          DropdownMenuItem(value: 'conduite', child: Text('Conduite')),
          DropdownMenuItem(value: 'code', child: Text('Code')),
          DropdownMenuItem(value: 'parking', child: Text('Parking')),
        ],
        onChanged: (value) => setState(() => _type = value ?? _type),
        decoration: InputDecoration(
          labelText: 'Type',
          labelStyle: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF64748B)),
          prefixIcon: const Icon(Icons.local_offer_outlined, size: 20, color: Color(0xFF1E2F45)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future<AdminUser?> _openSelection(BuildContext context, String title, List<AdminUser> users) {
    return showModalBottomSheet<AdminUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SelectionSheet(title: title, users: users),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final candidatId = _candidat?.candidatId ?? widget.seance.candidatId;
    final personnelId = _moniteur?.personnelId ?? widget.seance.personnelId;
    final durationError = _validateDuration(_dureeController.text);
    if (durationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(durationError), backgroundColor: const Color(0xFFF59E0B)),
      );
      return;
    }
    if (_moniteur != null && _isPersonnelCode(_moniteur!) && _type != 'code') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le personnel code peut seulement faire des séances Code.'), backgroundColor: Color(0xFFF59E0B)),
      );
      return;
    }
    final updated = Seance(
      id: widget.seance.id,
      date: _date,
      heure: _formatTimeOfDay(_time),
      type: _type,
      candidatId: candidatId,
      personnelId: personnelId,
      statut: widget.seance.statut,
      duree: _dureeController.text.trim().isEmpty ? widget.seance.duree : _dureeController.text.trim(),
      remarque: _remarqueController.text.trim(),
      candidatName: widget.seance.candidatName,
      moniteurName: widget.seance.moniteurName,
      candidatAvatar: widget.seance.candidatAvatar,
      moniteurAvatar: widget.seance.moniteurAvatar,
      candidatEmail: widget.seance.candidatEmail,
      moniteurEmail: widget.seance.moniteurEmail,
    );
    await context.read<SeanceCubit>().updateSeance(updated);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Séance mise à jour'), backgroundColor: Color(0xFF16A34A)),
      );
    }
  }

  static String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd/$mm/${date.year}';
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static bool _isPersonnelCode(AdminUser user) {
    final role = user.role.toLowerCase();
    return role.contains('personnel') && role.contains('code');
  }

  static String? _validateDuration(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'Durée requise';
    final match = RegExp(r'^\d+([.,]\d+)?$').hasMatch(text);
    if (!match) return 'Durée invalide (ex: 1 ou 1.5)';
    final normalized = text.replaceAll(',', '.');
    final hours = double.tryParse(normalized);
    if (hours == null || hours <= 0) return 'Durée invalide';
    return null;
  }
}

class _SelectionSheet extends StatefulWidget {
  final String title;
  final List<AdminUser> users;

  const _SelectionSheet({required this.title, required this.users});

  @override
  State<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final items = widget.users.where((u) {
      return u.fullName.toLowerCase().contains(query) || u.email.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final user = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2E86C1).withValues(alpha: 0.1),
                    child: Text(user.fullName.isNotEmpty ? user.fullName[0] : '?', style: GoogleFonts.lexend(color: const Color(0xFF2E86C1))),
                  ),
                  title: Text(user.fullName, style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                  subtitle: Text(user.email, style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF94A3B8))),
                  onTap: () => Navigator.pop(context, user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
