import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/admin_user_model.dart';
import '../../data/services/user_service.dart';

class UserManagementState {
  final List<AdminUser> users;
  final List<AdminUser> filteredUsers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String role;
  final String query;
  final DateTime? lastUpdated; // To trigger UI refresh

  const UserManagementState({
    required this.users,
    required this.filteredUsers,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.role,
    required this.query,
    this.error,
    this.lastUpdated,
  });

  factory UserManagementState.initial(String role) {
    return UserManagementState(
      users: const [],
      filteredUsers: const [],
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      error: null,
      role: role,
      query: '',
    );
  }

  UserManagementState copyWith({
    List<AdminUser>? users,
    List<AdminUser>? filteredUsers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? role,
    String? query,
    DateTime? lastUpdated,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      role: role ?? this.role,
      query: query ?? this.query,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserService _service;
  int _page = 1;

  UserManagementCubit(this._service) : super(UserManagementState.initial('candidat'));

  Future<void> loadInitial(String role) async {
    _page = 1;
    emit(state.copyWith(isLoading: true, error: null, role: role));
    try {
      final result = await _service.fetchAllUsers(role: '', page: _page);
      emit(state.copyWith(
        users: result.users,
        filteredUsers: _applyFilter(result.users, role, state.query),
        hasMore: result.hasMore,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      _page += 1;
      final result = await _service.fetchAllUsers(role: '', page: _page);
      final merged = [...state.users, ...result.users];
      emit(state.copyWith(
        users: merged,
        filteredUsers: _applyFilter(merged, state.role, state.query),
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  void updateQuery(String query) {
    emit(state.copyWith(
      query: query,
      filteredUsers: _applyFilter(state.users, state.role, query),
    ));
  }

  Future<void> createUser(AdminUser user) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (kDebugMode) print('CREATING USER: ${user.toJson()}');
      final result = await _service.createUser(user);
      if (kDebugMode) print('CREATE SUCCESS: ${result.fullName}');
      
      final updatedList = [result, ...state.users]; // Add new user to start of list

      emit(state.copyWith(
        users: updatedList,
        filteredUsers: _applyFilter(updatedList, state.role, state.query),
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      if (kDebugMode) print('CREATE ERROR: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateUser(AdminUser user) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (kDebugMode) print('UPDATING USER: ${user.toJson()}');
      final result = await _service.updateUser(user);
      if (kDebugMode) print('UPDATE SUCCESS: ${result.fullName}');
      
      final updatedList = state.users.map((item) {
        // Match by ID carefully
        return (item.id == result.id || item.id == user.id) ? result : item;
      }).toList();

      emit(state.copyWith(
        users: updatedList,
        filteredUsers: _applyFilter(updatedList, state.role, state.query),
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      if (kDebugMode) print('UPDATE ERROR: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteUser(AdminUser user) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _service.deleteUser(user.id);
      final updatedList = state.users.where((item) => item.id != user.id).toList();
      emit(state.copyWith(
        users: updatedList,
        filteredUsers: _applyFilter(updatedList, state.role, state.query),
        isLoading: false,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  List<AdminUser> _applyFilter(List<AdminUser> users, String role, String query) {
    var filtered = users.where((u) {
      final String r = u.role.toLowerCase();
      if (role == 'candidat') return r.contains('candidat') || r.contains('eleve') || r.contains('student');
      if (role == 'moniteur') return r.contains('moniteur') || r.contains('instructor') || r.contains('formateur');
      if (role == 'personnel') return r.contains('personnel') || r.contains('admin') || r.contains('staff') || r.contains('secretaire');
      return true;
    }).toList();

    if (query.trim().isEmpty) return filtered;
    final q = query.toLowerCase();
    return filtered.where((user) {
      return user.fullName.toLowerCase().contains(q) ||
          user.email.toLowerCase().contains(q) ||
          user.login.toLowerCase().contains(q) ||
          user.telephone.toLowerCase().contains(q);
    }).toList();
  }
}
