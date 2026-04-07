import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/auth_cubit.dart';
import '../widgets/premium_widgets.dart';
import '../../../../core/architecture/base_state.dart' as base;
import '../../data/models/user_model.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _otpSent = false;
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: Column(
                      children: [
                        // IDENTICAL BRANDING
                        Container(
                          height: 120, width: 120, padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 15))]),
                          child: ClipOval(child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover)),
                        ),
                        const SizedBox(height: 32),
                        Text('Auto École', style: GoogleFonts.lexend(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                        Text('Élite Conduite', style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold, color: accentOrange, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 48),

                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20))]),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_otpSent ? 'RÉINSTALLATION' : 'RÉCUPÉRATION', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 1.2)),
                                const SizedBox(height: 16),
                                
                                if (!_otpSent) ...[
                                  _buildInputField(controller: _loginController, label: 'Identifiant / Email', icon: Icons.person_outline_rounded),
                                ] else ...[
                                  _buildInputField(controller: _otpController, label: 'Code reçu', icon: Icons.lock_clock_outlined, type: TextInputType.number),
                                  const SizedBox(height: 16),
                                  _buildInputField(controller: _passwordController, label: 'Nouveau mot de passe', icon: Icons.lock_outline_rounded, isPassword: true, isObscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
                                  const SizedBox(height: 16),
                                  _buildInputField(controller: _confirmPasswordController, label: 'Confirmation', icon: Icons.lock_reset_rounded, isPassword: true, isObscure: _obscurePassword),
                                ],

                                const SizedBox(height: 32),
                                BlocConsumer<AuthCubit, base.BaseState<UserModel>>(
                                  listener: (context, state) {
                                    if (state is base.Error) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((state as base.Error).message), backgroundColor: Colors.redAccent));
                                    } else if (state is base.SuccessNoData) {
                                      setState(() => _otpSent = true);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code envoyé avec succès !'), backgroundColor: Colors.green));
                                    }
                                  },
                                  builder: (context, state) {
                                    return ActionButton(
                                      text: _otpSent ? 'RÉINITIALISER' : 'ENVOYER LE CODE', 
                                      isLoading: state is base.Loading, 
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          if (!_otpSent) {
                                            context.read<AuthCubit>().requestPasswordReset(_loginController.text);
                                          } else {
                                             context.read<AuthCubit>().resetPassword(
                                               _loginController.text, 
                                               _otpController.text, 
                                               _passwordController.text, 
                                               _confirmPasswordController.text
                                             );
                                          }
                                        }
                                      }
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, bool isObscure = false, VoidCallback? onToggle, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: type,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E86C1), size: 18),
        suffixIcon: isPassword ? IconButton(icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18), onPressed: onToggle) : null,
      ),
      validator: (v) => v!.isEmpty ? 'Requis' : null,
    );
  }
}
