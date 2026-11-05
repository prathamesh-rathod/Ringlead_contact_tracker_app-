import 'package:flutter/material.dart';
import '../models/api_exception.dart';
import '../services/auth_repository.dart';
import '../theme.dart';
import '../widgets/neu.dart';
import 'login_screen.dart' show FormErrorNote;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool get _businessNameValid => _businessNameController.text.trim().isNotEmpty;
  bool get _emailValid => _emailPattern.hasMatch(_emailController.text.trim());
  bool get _passwordValid => _passwordController.text.length >= 6;
  bool get _formValid => _businessNameValid && _emailValid && _passwordValid && !_submitting;

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthRepository.instance.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        businessName: _businessNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      // Registration signs the user in — pop back so the root session gate
      // (now signedIn) is revealed underneath this pushed route.
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      autocorrect: false,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink),
      decoration: InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Start tracking your calls',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.4),
              ),
              const SizedBox(height: 5),
              const Text('Free to start. No card needed.', style: AppText.caption),
              const SizedBox(height: 20),
              NeuCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledField(
                      label: 'Business name',
                      child: _textField(
                        controller: _businessNameController,
                        hint: 'Acme Roofing Co.',
                        capitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Email',
                      child: _textField(
                        controller: _emailController,
                        hint: 'you@business.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Phone (optional)',
                      child: _textField(
                        controller: _phoneController,
                        hint: '+91 98765 43210',
                        keyboardType: TextInputType.phone,
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
                                if (_formValid) _register();
                              },
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: 'At least 6 characters',
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
                        : NeuPrimaryButton(label: 'Create account', onPressed: _formValid ? _register : null),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
