import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/auth_cubit.dart';
import '../widgets/premium_widgets.dart';
import '../../../admin/presentation/pages/admin_main_screen.dart';
import 'admin_register_page.dart';
import 'forgot_password_page.dart';
import 'verification_page.dart';
import '../../../../core/architecture/base_state.dart' as base;
import '../../data/models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF1E293B);
    const Color accentOrange = Color(0xFFEB984E);

    return Scaffold(
      backgroundColor: darkNavy,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [darkNavy, darkNavy.withValues(alpha: 0.8)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 120, width: 120, padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 15))]),
                      child: ClipOval(child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover)),
                    ),
                    const SizedBox(height: 32),
                    Text('Auto École', style: GoogleFonts.lexend(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                    Text('Élite Conduite', style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold, color: accentOrange, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20))]),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Identifiant / Email'),
                            const SizedBox(height: 8),
                            _buildInputField(controller: _loginController, hint: 'Votre login ou email', icon: Icons.person_outline_rounded),
                            const SizedBox(height: 24),
                            _buildLabel('Mot de passe'),
                            const SizedBox(height: 8),
                            _buildInputField(controller: _passwordController, hint: '••••••••', icon: Icons.lock_outline_rounded, isPassword: true, isObscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
                            const SizedBox(height: 12),
                            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())), child: const Text('Oublié ?', style: TextStyle(color: accentOrange, fontWeight: FontWeight.w900, fontSize: 13)))),
                            const SizedBox(height: 24),
                            BlocConsumer<AuthCubit, base.BaseState<UserModel>>(
                              listener: (context, state) {
                                if (state is base.Error) {
                                  final msg = (state as base.Error).message.toLowerCase();
                                  if (msg.contains("otp") || msg.contains("verifie")) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => VerificationPage(login: _loginController.text, password: _passwordController.text)));
                                  } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((state as base.Error).message), backgroundColor: Colors.redAccent)); }
                                } else if (state is base.Success<UserModel>) {
                                  if (state.data.roleName.toLowerCase().contains('admin')) {
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AdminMainScreen()), (r) => false);
                                  } else { Navigator.pop(context); }
                                }
                              },
                              builder: (context, state) {
                                return ActionButton(text: 'SE CONNECTER', isLoading: state is base.Loading, onPressed: () => _formKey.currentState!.validate() ? context.read<AuthCubit>().login(_loginController.text, _passwordController.text) : null);
                              },
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterPage())),
                                child: RichText(
                                  text: const TextSpan(
                                    text: "Pas de compte ? ",
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    children: [
                                      TextSpan(text: "Inscription Admin", style: TextStyle(color: Color(0xFF2E86C1), fontWeight: FontWeight.w900))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF64748B), letterSpacing: 0.5));
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool isObscure = false, VoidCallback? onToggle}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF2E86C1), size: 20),
        suffixIcon: isPassword ? IconButton(icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: onToggle) : null,
      ),
      validator: (v) => v!.isEmpty ? 'Requis' : null,
    );
  }
}
