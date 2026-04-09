import 'package:get_it/get_it.dart';
import '../../features/auth/presentation/view_models/auth_cubit.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository.dart';
import '../../features/admin/presentation/view_models/dashboard_cubit.dart';
import '../../features/admin/presentation/view_models/users_management_cubit.dart';
import '../../features/admin/data/datasources/user_remote_data_source.dart';
import '../../features/admin/data/services/user_service.dart';
import '../../features/admin/data/datasources/seance_remote_data_source.dart';
import '../../features/admin/data/services/seance_service.dart';
import '../../features/admin/presentation/view_models/seance_cubit.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/services/chat_service.dart';
import '../../features/chat/presentation/view_models/chat_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  sl.registerLazySingleton(() => AuthCubit(sl()));
  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton(() => AuthRemoteDataSource());
  
  // Features - Admin
  sl.registerLazySingleton(() => AdminRepository(sl()));
  sl.registerLazySingleton(() => AdminRemoteDataSource());

  // ViewModels
  sl.registerFactory(() => DashboardCubit(sl()));
  sl.registerLazySingleton(() => UserRemoteDataSource());
  sl.registerLazySingleton(() => UserService(sl()));
  sl.registerFactory(() => UserManagementCubit(sl()));
  sl.registerLazySingleton(() => SeanceRemoteDataSource());
  sl.registerLazySingleton(() => SeanceService(sl()));
  sl.registerFactory(() => SeanceCubit(sl(), sl()));

  // Chat
  sl.registerLazySingleton(() => ChatRemoteDataSource());
  sl.registerLazySingleton(() => ChatService(sl()));
  sl.registerFactory(() => ChatCubit(sl(), sl()));
}
