import 'package:door/features/components/custom_appbar.dart';
import 'package:door/features/components/custom_elevated_button.dart';
import 'package:door/features/components/custom_textfeild.dart';
import 'package:door/main.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/services/local_notification_manager.dart';
import 'package:door/services/models/auth_models.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _googleLoading = false;
  final _authService = AuthService();

  Future<void> _handleSuccessfulSignIn() async {
    LocalNotificationManager().startPolling(
      interval: const Duration(seconds: 30),
    );
    if (!mounted) return;
    context.pushReplacementNamed(RouteConstants.bottomNavBarScreen);
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final request = SignInRequest(
        email: _emailController.text.trim(),
        password: _password.text,
      );

      final response = await _authService.signIn(request);

      if (!mounted) return;

      if (response.success && response.data != null) {
        await _handleSuccessfulSignIn();
      } else {
        _showError(response.message ?? 'Sign in failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Network error: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);

    try {
      final response = await _authService.signInWithGoogle();
      if (!mounted) return;

      if (response.success && response.data != null) {
        await _handleSuccessfulSignIn();
      } else if ((response.message ?? '').isNotEmpty &&
          response.message != 'Google sign-in cancelled') {
        _showError(response.message ?? 'Google sign-in failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Google sign-in failed: $e');
    } finally {
      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(child: Text(message)),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: screenWidth - 20,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: _loading || _googleLoading ? null : _signInWithGoogle,
        icon: _googleLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const FaIcon(
                FontAwesomeIcons.google,
                size: 18,
                color: Colors.black87,
              ),
        label: Text(
          _googleLoading ? 'Signing in...' : 'Continue with Google',
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD0D7DE)),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: 'Sign In', centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              CustomTextField(
                radius: 6,
                controller: _emailController,
                hint: 'Enter your email',
                prefixIcon: const Icon(Icons.mail_outline),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                radius: 6,
                controller: _password,
                hint: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  return null;
                },
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.pushNamed(RouteConstants.forgotPasswordScreen);
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomElevatedButton(
                width: screenWidth - 20,
                height: 60,
                borderRadius: 50,
                label: 'Sign In',
                isLoading: _loading,
                onPressed: _signIn,
              ),
              const SizedBox(height: 16),
              _buildGoogleButton(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(RouteConstants.signUpScreen);
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
