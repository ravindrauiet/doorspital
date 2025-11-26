import 'package:door/features/components/custom_appbar.dart';
import 'package:door/features/components/custom_elevated_button.dart';
import 'package:door/features/components/custom_textfeild.dart';
import 'package:door/features/auth/components/socian_button.dart';
import 'package:door/main.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/services/models/auth_models.dart';
import 'package:door/utils/images/images.dart';
import 'package:door/utils/theme/colors.dart';
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
  final _authService = AuthService();

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
        // Successfully signed in
        context.pushReplacementNamed(RouteConstants.bottomNavBarScreen);
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

  void _showError(String message) {
    // Show detailed error in snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Details',
          onPressed: () {
            // Show full error in a dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Connection Error'),
                content: SingleChildScrollView(
                  child: Text(message),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
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
                prefixIcon: Icon(Icons.mail_outline),
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

              // Password
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
                label: "Sign In",
                isLoading: _loading,
                onPressed: _signIn,
              ),

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

              // OR divider
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 32),

              // Social stubs
              SocialButton(
                text: 'Sign in with Google',
                imageUrl: Images.googleLogo,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              SocialButton(
                text: 'Sign in with Facebook',
                imageUrl: Images.facebookLogo,
                onPressed: () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
