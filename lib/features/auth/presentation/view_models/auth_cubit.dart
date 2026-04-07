import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/architecture/base_state.dart' as base;
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthCubit extends Cubit<base.BaseState<UserModel>> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(base.Initial());

  Future<void> checkAuth() async {
    emit(base.Loading());
    final user = await _repository.me();
    user != null ? emit(base.Success(user)) : emit(base.Initial());
  }

  Future<void> login(String login, String password) async {
    emit(base.Loading());
    try {
      final device = Platform.isAndroid ? 'Android' : 'iOS';
      final user = await _repository.login(login, password, device);
      if (user.token != null) {
        emit(base.Success(user));
      } else {
        emit(base.Error('Verification required'));
      }
    } catch (e) {
      emit(base.Error(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(base.Initial());
  }

  Future<void> registerAdmin(Map<String, dynamic> data) async {
    emit(base.Loading());
    try {
      await _repository.registerAdmin(data);
      emit(base.Error('Verification required')); // Success but redirect to OTP
    } catch (e) {
      emit(base.Error(e.toString()));
    }
  }

  Future<void> verifyOtp(String login, String code) async {
    emit(base.Loading());
    try {
      final user = await _repository.verifyOtp(login, code);
      emit(base.Success(user));
    } catch (e) {
      emit(base.Error(e.toString()));
    }
  }

  Future<void> requestOtp(String login, String password) async {
    emit(base.Loading());
    try {
      await _repository.resendOtp(login, password);
      emit(base.SuccessNoData()); 
    } catch (e) {
      emit(base.Error(e.toString()));
    }
  }

  Future<void> requestPasswordReset(String identifier) async {
    emit(base.Loading());
    try {
      await _repository.requestPasswordReset(identifier);
      emit(base.SuccessNoData()); 
    } catch (e) {
      emit(base.Error(e.toString()));
    }
  }

  Future<void> resetPassword(String identifier, String code, String password, String passwordConfirm) async {
    emit(base.Loading());
    try {
      await _repository.resetPassword(identifier, code, password, passwordConfirm);
      emit(base.SuccessNoData());
    } catch (e) {
      emit(base.Error(e.toString()));
    }
  }
}
