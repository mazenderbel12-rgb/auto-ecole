import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/architecture/base_state.dart';
import '../../data/models/admin_stats_model.dart';
import '../../data/repositories/admin_repository.dart';

class DashboardCubit extends Cubit<BaseState<AdminStatsModel>> {
  final AdminRepository _repository;

  DashboardCubit(this._repository) : super(Initial());

  Future<void> fetchStats() async {
    emit(Loading());
    try {
      final data = await _repository.getDashboardStats();
      emit(Success(AdminStatsModel.fromJson(data)));
    } catch (e) {
      emit(Error(e.toString()));
    }
  }
}
