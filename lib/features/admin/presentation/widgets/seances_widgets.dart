import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/seance_model.dart';

class SeancesMonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime? selectedDate;
  final List<Seance> seances;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<DateTime> onMonthChange;
  final VoidCallback? onMonthTap;

  const SeancesMonthCalendar({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.seances,
    required this.onSelect,
    required this.onMonthChange,
    this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthDate = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstWeekday = monthDate.weekday; // 1=Mon
    final startOffset = firstWeekday - 1;
    final totalCells = 42;
    final datesWithSeances = seances
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: onMonthTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_monthName(month.month)} ${month.year}',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.expand_more_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _MonthNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () =>
                    onMonthChange(DateTime(month.year, month.month - 1, 1)),
              ),
              const SizedBox(width: 8),
              _MonthNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () =>
                    onMonthChange(DateTime(month.year, month.month + 1, 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _WeekdayLabel('L'),
              _WeekdayLabel('M'),
              _WeekdayLabel('M'),
              _WeekdayLabel('J'),
              _WeekdayLabel('V'),
              _WeekdayLabel('S'),
              _WeekdayLabel('D'),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final day = index - startOffset + 1;
              final inMonth = day >= 1 && day <= daysInMonth;
              final date = DateTime(month.year, month.month, day);
              final isSelected = inMonth && selectedDate != null && _isSameDate(date, selectedDate!);
              final hasSeance = inMonth && datesWithSeances.contains(date);
              return GestureDetector(
                onTap: inMonth ? () => onSelect(date) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2E86C1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        inMonth ? day.toString() : '',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (inMonth
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFCBD5E1)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (hasSeance)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFEB984E),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _monthName(int month) {
    const names = [
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
    return names[(month - 1).clamp(0, 11)];
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1E293B)),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 11,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

class SeancesAgendaView extends StatelessWidget {
  final DateTime date;
  final List<Seance> seances;
  final ValueChanged<Seance> onCancel;
  final ValueChanged<Seance>? onTap;

  const SeancesAgendaView({
    super.key,
    required this.date,
    required this.seances,
    required this.onCancel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (seances.isEmpty) {
      return const _EmptyAgenda();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final lineTop = _currentLineOffset(constraints.maxHeight);
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: seances.length,
              itemBuilder: (context, index) {
                final s = seances[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Dismissible(
                    key: ValueKey(s.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Annuler',
                        style: GoogleFonts.lexend(
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    confirmDismiss: (_) async {
                      onCancel(s);
                      return false;
                    },
                    child: SeanceCard(seance: s, onTap: () => onTap?.call(s)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  static double _currentLineOffset(double height) {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;
    final start = 6 * 60;
    final end = 22 * 60;
    final clamped = minutes.clamp(start, end);
    final ratio = (clamped - start) / (end - start);
    return 12 + ratio * (height - 24);
  }
}

class SeanceCard extends StatelessWidget {
  final Seance seance;
  final VoidCallback? onTap;

  const SeanceCard({super.key, required this.seance, this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(seance.type);
    final displayStatus = _effectiveStatus(seance);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon(seance.type), size: 16, color: typeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatDate(seance.date)} · ${_formatTime(seance.startDateTime)}–${_formatTime(seance.endDateTime)}',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    seance.candidatName ?? 'Candidat',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seance.moniteurName ?? 'Moniteur',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _StatusBadge(status: displayStatus),
          ],
        ),
      ),
    );
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

  static String _effectiveStatus(Seance seance) {
    final base = seance.statut.toLowerCase();
    if (base.contains('ann') || base.contains('term')) return base;
    final now = DateTime.now();
    if (now.isAfter(seance.startDateTime) ||
        now.isAtSameMomentAs(seance.startDateTime)) {
      if (now.isBefore(seance.endDateTime)) {
        return 'en_cours';
      }
    }
    return base;
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color color;
    String label;
    if (s.contains('term')) {
      color = const Color(0xFF16A34A);
      label = 'Terminé';
    } else if (s.contains('ann')) {
      color = const Color(0xFFDC2626);
      label = 'Annulé';
    } else if (s.contains('cours')) {
      color = const Color(0xFFEB984E);
      label = 'En cours';
    } else {
      color = const Color(0xFF2E86C1);
      label = 'Planifié';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  final String name;

  const _AvatarBubble({required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFF2E86C1).withValues(alpha: 0.1),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2E86C1),
        ),
      ),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  const _EmptyAgenda();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF2E86C1).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 44,
              color: Color(0xFF2E86C1),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune séance',
            style: GoogleFonts.lexend(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
