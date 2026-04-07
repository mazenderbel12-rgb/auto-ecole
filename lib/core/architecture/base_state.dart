import 'package:equatable/equatable.dart';

sealed class BaseState<T> extends Equatable {
  const BaseState();
  @override
  List<Object?> get props => [];
}

class Initial<T> extends BaseState<T> {}
class Loading<T> extends BaseState<T> {}
class Success<T> extends BaseState<T> {
  final T data;
  const Success(this.data);
  @override
  List<Object?> get props => [data];
}
class Error<T> extends BaseState<T> {
  final String message;
  const Error(this.message);
  @override
  List<Object?> get props => [message];
}
class SuccessNoData<T> extends BaseState<T> {
  const SuccessNoData();
}
