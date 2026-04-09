import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/models/seance_model.dart';
import '../view_models/seance_cubit.dart';

class SeanceFormSheet extends StatefulWidget {
  final Seance? seance;
  const SeanceFormSheet({super.key, this.seance});

  @override
  State<SeanceFormSheet> createState() => _SeanceFormSheetState();
}

class _SeanceFormSheetState extends State<SeanceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String _type = 'conduite';
  AdminUser? _candidat;
  AdminUser? _moniteur;

  @override
  void initState() {
    super.initState();
    if (widget.seance != null) {
      final s = widget.seance!;
      _date = s.date;
      _time = TimeOfDay(hour: s.startDateTime.hour, minute: s.startDateTime.minute);
      _type = s.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SeanceCubit>().state;
    if (widget.seance != null && (_candidat == null || _moniteur == null)) {
      final s = widget.seance!;
      for (final u in state.candidats) {
        if (u.candidatId != null && u.candidatId == s.candidatId) {
          _candidat = u;
          break;
        }
      }
      for (final u in state.moniteurs) {
        if (u.personnelId != null && u.personnelId == s.personnelId) {
          _moniteur = u;
          break;
        }
      }
    }
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
            Text(widget.seance == null ? 'Nouvelle Séance' : 'Modifier Séance', style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _buildDateField(context),
            const SizedBox(height: 12),
            _buildTimeField(context),
            const SizedBox(height: 12),
            _buildTypeDropdown(),
            const SizedBox(height: 12),
            _SelectionField(
              label: 'Candidat',
              value: _candidat?.fullName ?? widget.seance?.candidatName ?? '',
              onTap: () async {
                final user = await _openSelection(context, 'Choisir un candidat', state.candidats);
                if (user != null) setState(() => _candidat = user);
              },
            ),
            const SizedBox(height: 12),
            _SelectionField(
              label: 'Moniteur',
              value: _moniteur?.fullName ?? widget.seance?.moniteurName ?? '',
              onTap: () async {
                final user = await _openSelection(context, 'Choisir un moniteur', state.moniteurs);
                if (user != null) setState(() => _moniteur = user);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_candidat == null || _moniteur == null) return;
                        final candidatId = _candidat?.candidatId ?? widget.seance?.candidatId;
                        final personnelId = _moniteur?.personnelId ?? widget.seance?.personnelId;
                        if (candidatId == null || personnelId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Candidat ou moniteur invalide (ID manquant).'),
                              backgroundColor: Color(0xFFF59E0B),
                            ),
                          );
                          return;
                        }
                        if (widget.seance == null) {
                          final draft = SeanceDraft(
                            date: _date,
                            heure: _formatTimeOfDay(_time),
                            type: _type,
                            candidatId: candidatId,
                            personnelId: personnelId,
                          );
                          final ok = await context.read<SeanceCubit>().addSeance(draft);
                          if (ok && mounted) Navigator.pop(context);
                        } else {
                          final updated = Seance(
                            id: widget.seance!.id,
                            date: _date,
                            heure: _formatTimeOfDay(_time),
                            type: _type,
                            candidatId: candidatId,
                            personnelId: personnelId,
                            statut: widget.seance!.statut,
                            duree: widget.seance!.duree,
                            remarque: widget.seance!.remarque,
                            candidatName: widget.seance!.candidatName,
                            moniteurName: widget.seance!.moniteurName,
                            candidatAvatar: widget.seance!.candidatAvatar,
                            moniteurAvatar: widget.seance!.moniteurAvatar,
                          );
                          await context.read<SeanceCubit>().updateSeance(updated);
                          if (mounted) Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E86C1)),
                child: state.isSubmitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.seance == null ? 'Valider' : 'Enregistrer', style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return _SelectionField(
      label: 'Date',
      value: _formatDate(_date),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _date = picked);
      },
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return _SelectionField(
      label: 'Heure',
      value: _time.format(context),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: _time);
        if (picked != null) setState(() => _time = picked);
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _type,
      items: const [
        DropdownMenuItem(value: 'conduite', child: Text('Conduite')),
        DropdownMenuItem(value: 'code', child: Text('Code')),
        DropdownMenuItem(value: 'parking', child: Text('Parking')),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _type = value);
      },
      decoration: InputDecoration(
        labelText: 'Type',
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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

  static String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _SelectionField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SelectionField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
        child: Text(value.isEmpty ? 'Sélectionner' : value, style: GoogleFonts.lexend()),
      ),
    );
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
