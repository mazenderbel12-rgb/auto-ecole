import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/models/seance_model.dart';
import '../view_models/seance_cubit.dart';
import '../widgets/seances_widgets.dart';
import '../widgets/admin_drawer.dart';
import 'seance_details_page.dart';
import 'add_seance_page.dart';

class SeancesPage extends StatefulWidget {
  const SeancesPage({super.key});

  @override
  State<SeancesPage> createState() => _SeancesPageState();
}

class _SeancesPageState extends State<SeancesPage> {
  late final SeanceCubit _cubit;
  String _filter = 'toutes';
  bool _calendarExpanded = true;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _searchOpen = false;
  DateTime _calendarMonth = DateTime.now();
  DateTime? _selectedDate;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _cubit = di.sl<SeanceCubit>();
    _cubit.loadInitial();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: const AdminDrawer(),
        floatingActionButton: null,
        body: SafeArea(
          child: BlocConsumer<SeanceCubit, SeanceState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: const Color(0xFFF59E0B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              final filtered = _applyFilter(state.seances, _selectedDate, _filter, _query);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B), size: 28),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PLANIFICATION', style: GoogleFonts.lexend(fontSize: 11, letterSpacing: 1, color: const Color(0xFF94A3B8))),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                                  children: const [
                                    TextSpan(text: 'Mes '),
                                    TextSpan(text: 'Seances', style: TextStyle(color: Color(0xFFEB984E))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _CircleIconButton(
                          icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                          onTap: () {
                            setState(() {
                              _searchOpen = !_searchOpen;
                              if (_searchOpen) {
                                _calendarExpanded = false;
                              } else {
                                _searchController.clear();
                                _query = '';
                                _calendarExpanded = true;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _CircleIconButton(
                          icon: Icons.add_rounded,
                          onTap: () => _openAddPage(context),
                          filled: true,
                        ),
                      ],
                    ),
                  ),
                  if (_searchOpen)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        style: GoogleFonts.lexend(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Rechercher candidat ou personnel...',
                          hintStyle: GoogleFonts.lexend(color: const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text('Calendrier', style: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                          const Spacer(),
                          IconButton(
                            onPressed: () => setState(() => _calendarExpanded = !_calendarExpanded),
                            icon: Icon(_calendarExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: const Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _calendarExpanded
                          ? SeancesMonthCalendar(
                              month: _calendarMonth,
                              selectedDate: _selectedDate,
                              seances: state.seances,
                              onSelect: (date) {
                                setState(() {
                                  if (_selectedDate != null && _isSameDate(_selectedDate!, date)) {
                                    _selectedDate = null;
                                  } else {
                                    _selectedDate = date;
                                  }
                                });
                              },
                              onMonthChange: (month) => setState(() => _calendarMonth = month),
                              onMonthTap: () => _pickMonth(context, _calendarMonth),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _FilterChip(label: 'Toutes', selected: _filter == 'toutes', onTap: () => setState(() => _filter = 'toutes')),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'Conduite', selected: _filter == 'conduite', onTap: () => setState(() => _filter = 'conduite')),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'Code', selected: _filter == 'code', onTap: () => setState(() => _filter = 'code')),
                        const SizedBox(width: 8),
                        _FilterChip(label: 'Parking', selected: _filter == 'parking', onTap: () => setState(() => _filter = 'parking')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOUTES LES SEANCES', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.4)),
                        Text('${filtered.length} seances', style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E86C1)))
                        : SeancesAgendaView(
                            date: state.selectedDate,
                            seances: filtered,
                            onCancel: (s) => context.read<SeanceCubit>().cancelSeance(s),
                            onTap: (s) => _openSeanceDetails(context, s),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openAddPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SeanceCubit>(),
          child: const AddSeancePage(),
        ),
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context, DateTime current) async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => _MonthYearPickerDialog(initial: current),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _calendarMonth = picked);
  }

  static List<Seance> _applyFilter(List<Seance> items, DateTime? selectedDate, String filter, String query) {
    var filtered = selectedDate == null
        ? List<Seance>.from(items)
        : items.where((s) => _isSameDate(s.date, selectedDate)).toList();
    if (filter != 'toutes') {
      filtered = filtered.where((s) => s.type.toLowerCase() == filter).toList();
    }
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return filtered;
    return filtered.where((s) {
      final candidat = (s.candidatName ?? '').toLowerCase();
      final moniteur = (s.moniteurName ?? '').toLowerCase();
      return candidat.contains(q) || moniteur.contains(q);
    }).toList();
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _openSeanceDetails(BuildContext context, Seance seance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SeanceCubit>(),
          child: SeanceDetailsPage(seanceId: seance.id, initialSeance: seance),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _CircleIconButton({required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Icon(icon, color: filled ? Colors.white : const Color(0xFF1E293B)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
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

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initial;

  const _MonthYearPickerDialog({required this.initial});

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  static const List<String> _months = [
    'Janvier',
    'Fevrier',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Aout',
    'Septembre',
    'Octobre',
    'Novembre',
    'Decembre',
  ];

  late int _year;
  late int _monthIndex;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _monthIndex = widget.initial.month - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choisir un mois', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _year -= 1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Center(
                    child: Text('$_year', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _year += 1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _months.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (context, index) {
                final selected = index == _monthIndex;
                return GestureDetector(
                  onTap: () => setState(() => _monthIndex = index),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF2E86C1) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _months[index],
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E86C1)),
                    onPressed: () {
                      final picked = DateTime(_year, _monthIndex + 1, 1);
                      Navigator.pop(context, picked);
                    },
                    child: const Text('Valider', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
