import 'package:flutter/material.dart';
import '../models/api_exception.dart';
import '../services/auth_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool get _emailValid => _emailPattern.hasMatch(_emailController.text.trim());
  bool get _passwordValid => _passwordController.text.length >= 6;
  bool get _formValid => _emailValid && _passwordValid && !_submitting;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthRepository.instance.login(_emailController.text.trim(), _passwordController.text);
      // AuthRepository flips to signedIn — the root session gate swaps to AppShell.
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 36, 22, 24),
          child: Column(
            children: [
              const BrandMark(),
              const SizedBox(height: 18),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.6),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to track every call and lead.',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
              const SizedBox(height: 28),
              NeuCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledField(
                      label: 'Email',
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: 'you@business.com',
                          hintStyle: TextStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Password',
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) {
                                if (_formValid) _login();
                              },
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 19,
                              color: AppColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      FormErrorNote(message: _error!),
                    ],
                    const SizedBox(height: 20),
                    _submitting
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Center(child: CircularProgressIndicator(color: AppColors.blue, strokeWidth: 2.4)),
                          )
                        : NeuPrimaryButton(label: 'Sign in', onPressed: _formValid ? _login : null),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _submitting
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text.rich(
                  TextSpan(
                    text: 'New to Ringlead?  ',
                    style: AppText.caption,
                    children: [TextSpan(text: 'Create an account', style: AppText.link)],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'By continuing you agree to the Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppText.tiny,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Square brand tile used on the auth screens and the splash.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 62});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.32),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2F6BFF), Color(0xFF1B3FB8)],
            ),
            boxShadow: AppShadows.tinted(AppColors.blue),
          ),
          child: Icon(Icons.graphic_eq_rounded, size: size * 0.46, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ringlead',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: 0.2),
        ),
      ],
    );
  }
}

/// Inline validation / server error message inside a form card.
class FormErrorNote extends StatelessWidget {
  const FormErrorNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.redInk),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w500, color: AppColors.redInk),
            ),
          ),
        ],
      ),
    );
  }
}
