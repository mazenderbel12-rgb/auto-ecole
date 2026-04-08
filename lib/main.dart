import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/view_models/auth_cubit.dart';
import 'features/admin/presentation/pages/admin_main_screen.dart';
import 'core/architecture/base_state.dart' as base;
import 'features/auth/data/models/user_model.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthCubit>()..checkAuth(),
      child: MaterialApp(
        title: 'Driving School CRM',
        theme: AppTheme.whiteProfessionalTheme,
        debugShowCheckedModeBanner: false,
        home: const AppLanding(),
      ),
    );
  }
}

class AppLanding extends StatelessWidget {
  const AppLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, base.BaseState<UserModel>>(
      builder: (context, state) {
        if (state is base.Loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (state is base.Success<UserModel>) {
          final user = state.data;
          if (user.roleName.toLowerCase().contains('admin')) {
             return const AdminMainScreen();
          }
          
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_person_rounded, size: 80, color: Colors.blueAccent),
                  const SizedBox(height: 24),
                  const Text('Espace en cours de développement.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.read<AuthCubit>().logout(),
                    child: const Text('Déconnexion'),
                  ),
                ],
              ),
            ),
          );
        }

        return const WelcomePage();
      },
    );
  }
}
