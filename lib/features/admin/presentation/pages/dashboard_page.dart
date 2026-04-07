import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/architecture/base_state.dart' as base;
import '../../../../core/di/injection_container.dart' as di;
import '../../data/models/admin_stats_model.dart';
import '../view_models/dashboard_cubit.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_activity_item.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2E86C1);
    const Color accentOrange = Color(0xFFEB984E);
    const Color darkNavy = Color(0xFF1E293B);
    const Color backgroundColor = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocProvider(
        create: (context) => di.sl<DashboardCubit>()..fetchStats(),
        child: BlocBuilder<DashboardCubit, base.BaseState<AdminStatsModel>>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().fetchStats(),
              color: primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state is base.Error) ...[
                      _buildErrorBanner(
                        (state as base.Error).message,
                        () => context.read<DashboardCubit>().fetchStats(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildStatsGrid(state, primaryBlue, accentOrange, darkNavy),
                    const SizedBox(height: 32),
                    _buildQuickActions(primaryBlue, darkNavy),
                    const SizedBox(height: 32),
                    _buildRecentActivity(state, darkNavy),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    base.BaseState<AdminStatsModel> state,
    Color blue,
    Color orange,
    Color dark,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatTile('Candidats', state, (s) => s.candidats, Icons.people_rounded, blue),
        _buildStatTile('Revenu', state, (s) => s.revenu, Icons.monetization_on_rounded, orange),
        _buildStatTile('Seances', state, (s) => s.seances, Icons.calendar_today_rounded, blue),
        _buildStatTile('Reussite', state, (s) => s.reussite, Icons.trending_up_rounded, dark),
      ],
    );
  }

  Widget _buildStatTile(
    String title,
    base.BaseState<AdminStatsModel> state,
    String Function(AdminStatsModel) valueGetter,
    IconData icon,
    Color color,
  ) {
    if (state is base.Loading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    }

    final value = state is base.Success<AdminStatsModel> ? valueGetter(state.data) : '--';
    return StatCard(title: title, count: value, icon: icon, color: color);
  }

  Widget _buildQuickActions(Color blue, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w900, color: textColor),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionIcon(Icons.person_add_rounded, 'Nouveau', blue),
            _buildActionIcon(Icons.calendar_month_rounded, 'Seance', blue),
            _buildActionIcon(Icons.payments_rounded, 'Paiement', textColor),
            _buildActionIcon(Icons.more_horiz_rounded, 'Plus', blue),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(base.BaseState<AdminStatsModel> state, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Activite Recente',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w900, color: textColor),
            ),
            Text(
              'Tout voir',
              style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2E86C1)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state is base.Loading)
          _buildShimmerList()
        else if (state is base.Success<AdminStatsModel> && state.data.activities.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.data.activities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = state.data.activities[index];
              return RecentActivityItem(text: activity.text, time: activity.time);
            },
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Aucune activite recente',
              style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        3,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.white,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7F1D1D),
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Reessayer')),
        ],
      ),
    );
  }
}
