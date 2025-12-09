// lib/sign_up_screen.dart
import 'package:door/features/components/custom_appbar.dart';
import 'package:door/features/components/custom_elevated_button.dart';
import 'package:door/features/components/custom_textfeild.dart';
import 'package:door/features/auth/provider/check_box_provider.dart';
import 'package:door/routes/route_constants.dart';
import 'package:door/services/auth_service.dart';
import 'package:door/services/models/auth_models.dart';
import 'package:door/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  void _showError(String message) {
    // Show error in snackbar with close button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(message),
            ),
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

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final checkBoxProvider = context.read<CheckBoxProvider>();
    if (!checkBoxProvider.agreeTos) {
      _showError('Please agree to the Terms of Service');
      return;
    }

    checkBoxProvider.setLoading(true);

    try {
      final request = SignUpRequest(
        userName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final response = await _authService.signUp(request);

      if (!mounted) return;

      if (response.success) {
        // Successfully signed up
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Sign up successful'),
            duration: const Duration(seconds: 3),
          ),
        );
        // Navigate to sign in or home
        context.pushReplacementNamed(RouteConstants.signInScreen);
      } else {
        _showError(response.message ?? 'Sign up failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Network error: $e');
    } finally {
      if (mounted) {
        checkBoxProvider.setLoading(false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkBoxProvider = context.watch<CheckBoxProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(title: 'Sign Up', centerTitle: true),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    CustomTextField(
                      radius: 6,
                      controller: _nameController,
                      hint: 'Enter your name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      radius: 6,
                      controller: _emailController,
                      hint: 'Enter your email',
                      prefixIcon: const Icon(Icons.mail_outline),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      radius: 6,
                      controller: _passwordController,
                      hint: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: checkBoxProvider.agreeTos,
                          activeColor: AppColors.primary,
                          onChanged: checkBoxProvider.toggleAgree,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Wrap(
                            children: [
                              Text(
                                'I agree to the healthcare ',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.pushNamed(
                                  RouteConstants.termsAndConditionsScreen,
                                ),
                                child: Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.teal,
                                  ),
                                ),
                              ),
                              Text(
                                ' and ',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.pushNamed(
                                  RouteConstants.privacyPolicyScreen,
                                ),
                                child: Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomElevatedButton(
                      width: double.infinity,
                      height: 60,
                      borderRadius: 50,
                      label: 'Sign Up',
                      isLoading: checkBoxProvider.loading,
                      onPressed: checkBoxProvider.agreeTos ? _signUp : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.pushNamed(RouteConstants.signInScreen),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
