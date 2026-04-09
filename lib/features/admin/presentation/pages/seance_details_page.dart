import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/seance_model.dart';
import '../view_models/seance_cubit.dart';
import 'edit_seance_page.dart';

class SeanceDetailsPage extends StatelessWidget {
  final String seanceId;
  final Seance? initialSeance;
  const SeanceDetailsPage({super.key, required this.seanceId, this.initialSeance});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeanceCubit, SeanceState>(
      builder: (context, state) {
        final current = state.seances.where((s) => s.id == seanceId).toList();
        final seance = current.isNotEmpty ? current.first : initialSeance;
        if (seance == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: const Color(0xFF1E2F45),
              foregroundColor: Colors.white,
              title: Text('Séance', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            body: Center(
              child: Text(
                'Séance introuvable',
                style: GoogleFonts.lexend(fontSize: 14, color: const Color(0xFF64748B)),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, seance),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('INFORMATIONS SÉANCE'),
                      const SizedBox(height: 16),
                      _buildInfoCard(seance),
                      const SizedBox(height: 24),
                      _buildSectionTitle('PARTICIPANTS'),
                      const SizedBox(height: 16),
                      _buildParticipantsCard(seance),
                      if ((seance.remarque ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionTitle('REMARQUE'),
                        const SizedBox(height: 16),
                        _buildRemarkCard(seance),
                      ],
                      const SizedBox(height: 24),
                      _buildActionButtons(context, seance),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Seance seance) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF1E2F45),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Séance', style: GoogleFonts.lexend(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: Icon(_typeIcon(seance.type), color: _typeColor(seance.type), size: 34),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeLabel(seance.type),
                        style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatusChip(status: seance.statut),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatDate(seance.date)} · ${_formatTime(seance.startDateTime)}–${_formatTime(seance.endDateTime)}',
                            style: GoogleFonts.lexend(fontSize: 11, color: Colors.white70),
                          ),
                        ],
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
    return Text(
      title,
      style: GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildInfoCard(Seance seance) {
    return _card(
      Column(
        children: [
          _infoItem(Icons.calendar_today_outlined, 'Date', _formatDate(seance.date), const Color(0xFFEB984E)),
          _divider(),
          _infoItem(Icons.access_time_rounded, 'Heure', '${_formatTime(seance.startDateTime)} - ${_formatTime(seance.endDateTime)}', const Color(0xFF2E86C1)),
          _divider(),
          _infoItem(Icons.local_offer_outlined, 'Type', _typeLabel(seance.type), _typeColor(seance.type)),
          _divider(),
          _infoItem(Icons.timer_outlined, 'Durée', _formatDuration(seance.duree), const Color(0xFF16A34A)),
          _divider(),
          _infoItem(Icons.flag_outlined, 'Statut', _statusLabel(seance.statut), _statusColor(seance.statut)),
        ],
      ),
    );
  }

  Widget _buildParticipantsCard(Seance seance) {
    return _card(
      Column(
        children: [
          _infoItem(Icons.person_outline_rounded, 'Candidat', seance.candidatName ?? '-', const Color(0xFF5DADE2)),
          _divider(),
          _infoItem(Icons.email_outlined, 'Email candidat', seance.candidatEmail ?? '-', const Color(0xFF5DADE2)),
          _divider(),
          _infoItem(Icons.badge_outlined, 'Moniteur / Personnel', seance.moniteurName ?? '-', const Color(0xFF5DADE2)),
          _divider(),
          _infoItem(Icons.email_outlined, 'Email moniteur', seance.moniteurEmail ?? '-', const Color(0xFF5DADE2)),
        ],
      ),
    );
  }

  Widget _buildRemarkCard(Seance seance) {
    return _card(
      Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          seance.remarque ?? '',
          style: GoogleFonts.lexend(fontSize: 13, color: const Color(0xFF1E293B)),
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: child,
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

  Widget _buildActionButtons(BuildContext context, Seance seance) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openEdit(context, seance),
            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
            label: Text('Modifier', style: GoogleFonts.lexend(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2F45),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, seance),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text('Supprimer', style: GoogleFonts.lexend(fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEB984E),
              side: const BorderSide(color: Color(0xFFEB984E), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }

  void _openEdit(BuildContext context, Seance seance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SeanceCubit>(),
          child: EditSeancePage(seance: seance),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Seance seance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmer la suppression', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer cette séance ?', style: GoogleFonts.lexend()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Annuler', style: GoogleFonts.lexend(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<SeanceCubit>().deleteSeance(seance);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Supprimer', style: GoogleFonts.lexend(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd/$mm/${date.year}';
  }

  static String _formatDuration(String? value) {
    if (value == null || value.trim().isEmpty) return '1h';
    return value;
  }

  static String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'code':
        return 'Code';
      case 'parking':
        return 'Parking';
      default:
        return 'Conduite';
    }
  }

  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'code':
        return const Color(0xFFEB984E);
      case 'parking':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF2E86C1);
    }
  }

  static IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'code':
        return Icons.menu_book_rounded;
      case 'parking':
        return Icons.local_parking_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  static String _statusLabel(String status) {
    final s = status.toLowerCase();
    if (s.contains('term')) return 'Terminé';
    if (s.contains('ann')) return 'Annulé';
    if (s.contains('cours')) return 'En cours';
    return 'Planifié';
  }

  static Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('term')) return const Color(0xFF16A34A);
    if (s.contains('ann')) return const Color(0xFFDC2626);
    if (s.contains('cours')) return const Color(0xFFEB984E);
    return const Color(0xFF2E86C1);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = SeanceDetailsPage._statusLabel(status);
    final color = SeanceDetailsPage._statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
