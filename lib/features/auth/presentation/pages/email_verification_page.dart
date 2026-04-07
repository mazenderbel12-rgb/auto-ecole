import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/auth_cubit.dart';
import '../widgets/premium_widgets.dart';
import '../../../../core/architecture/base_state.dart' as base;
import '../../data/models/user_model.dart';

class EmailVerificationPage extends StatefulWidget {
  final String login;
  final String? password;
  const EmailVerificationPage({super.key, required this.login, this.password});
  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
                                const Text('VÉRIFICATION EMAIL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF64748B), letterSpacing: 1.2)),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 10),
                                  decoration: InputDecoration(
                                    labelText: 'Code de Sécurité',
                                    hintText: '000000',
                                    prefixIcon: const Icon(Icons.mark_email_unread_outlined, color: Color(0xFF2E86C1)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  validator: (v) => v!.length < 6 ? '6 chiffres' : null,
                                ),

                                const SizedBox(height: 32),
                                BlocConsumer<AuthCubit, base.BaseState<UserModel>>(
                                  listener: (context, state) {
                                    if (state is base.Success<UserModel>) {
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                    } else if (state is base.Error) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((state as base.Error).message), backgroundColor: Colors.redAccent));
                                    }
                                  },
                                  builder: (context, state) {
                                    return ActionButton(
                                      text: 'CONFIRMER LE CODE', 
                                      isLoading: state is base.Loading, 
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthCubit>().verifyOtp(widget.login, _otpController.text);
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
}
