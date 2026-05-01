import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'username': _usernameController.text.trim(), 'full_name': _fullNameController.text.trim()},
      );

      if (response.user != null) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppTheme.coral600),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppTheme.backgroundColor(isDark);
    final cardBg = AppTheme.cardColor(isDark);
    final textPrimary = AppTheme.textPrimary(isDark);
    final textSecondary = AppTheme.textSecondary(isDark);
    final cardBorder = AppTheme.cardBorder(isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppLogo(size: 64, showText: true),
                    const SizedBox(height: 40),
                    Text('Create your account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: textPrimary, letterSpacing: -0.02)),
                    const SizedBox(height: 8),
                    Text('Join the conversation', style: TextStyle(fontSize: 16, color: textSecondary)),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder, width: 0.5)),
                      child: TextFormField(
                        controller: _usernameController,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(labelText: 'Username', labelStyle: TextStyle(color: textSecondary), prefixIcon: Icon(Icons.alternate_email, color: textSecondary), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : (v!.length < 3 ? 'Min 3 chars' : null),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder, width: 0.5)),
                      child: TextFormField(
                        controller: _fullNameController,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(labelText: 'Full Name', labelStyle: TextStyle(color: textSecondary), prefixIcon: Icon(Icons.person_outlined, color: textSecondary), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder, width: 0.5)),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: textSecondary), prefixIcon: Icon(Icons.email_outlined, color: textSecondary), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder, width: 0.5)),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Password', labelStyle: TextStyle(color: textSecondary), prefixIcon: Icon(Icons.lock_outlined, color: textSecondary),
                          border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: textSecondary),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : (v!.length < 6 ? 'Min 6 chars' : null),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Sign Up'),
                    ),
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Already have an account? ', style: TextStyle(color: textSecondary)),
                      TextButton(onPressed: () => context.go('/login'), child: const Text('Sign In')),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}