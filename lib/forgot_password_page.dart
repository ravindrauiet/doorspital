// lib/forgot_password_page.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/* ───────────────── Host / Network ───────────────── */

/// Toggle this when testing on a REAL device and set your machine's LAN IP.
/// Example: const String kLanIp = '192.168.1.23';
const bool kUseLanIpForRealDevice = false;
const String kLanIp = '192.168.1.23';

String _resolveHost() {
  if (kUseLanIpForRealDevice) return kLanIp;
  if (kIsWeb) return 'localhost';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return '10.0.2.2';
    case TargetPlatform.iOS:
      return '127.0.0.1';
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return '127.0.0.1';
    default:
      return '127.0.0.1';
  }
}

/* ───────────────── Forgot Password Page ───────────────── */

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  // Optional resend cooldown (UI nicety; server still enforces limits)
  static const _cooldown = Duration(seconds: 30);
  DateTime? _cooldownUntil;
  Timer? _tick;

  late final String _endpointBase;

  @override
  void initState() {
    super.initState();
    _endpointBase = 'http://${_resolveHost()}:3000';
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_cooldownUntil == null) return;
      if (DateTime.now().isAfter(_cooldownUntil!)) {
        setState(() => _cooldownUntil = null);
      } else {
        // just refresh UI each second
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) {
    final s = v.trim();
    // Simple but effective email check
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(s);
  }

  Future<void> _sendResetEmail() async {
    final email = _emailCtrl.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    if (_cooldownUntil != null) return; // still cooling down
    setState(() => _loading = true);

    try {
      final uri = Uri.parse('$_endpointBase/auth/forgot-password');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> body = res.body.isNotEmpty
          ? json.decode(res.body)
          : {};

      if (res.statusCode == 200) {
        // Server never reveals if email exists — by design.
        final msg =
            (body['message'] as String?) ??
            'If this email exists, a reset link has been sent.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));

        // start local cooldown
        setState(() => _cooldownUntil = DateTime.now().add(_cooldown));

        // Optionally reveal previewUrl (e.g., Ethereal/Nodemailer)
        final preview = body['previewUrl'] as String?;
        if (preview != null && preview.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Preview: $preview')));
        }
      } else {
        // Show server-provided error or generic
        final err = (body['error'] as String?) ?? 'Could not send reset link';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _secondsLeft() {
    if (_cooldownUntil == null) return 0;
    final left = _cooldownUntil!.difference(DateTime.now()).inSeconds;
    return left > 0 ? left : 0;
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _secondsLeft();
    final disabled = _loading || seconds > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            const Text(
              'We’ll email you a secure link to reset your password. '
              'The link is valid for 5 minutes.',
              style: TextStyle(color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Email address',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => (v == null || !_isValidEmail(v))
                    ? 'Enter a valid email'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: disabled
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _sendResetEmail();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4FE3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        seconds > 0
                            ? 'Resend in ${seconds}s'
                            : 'Send reset link',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const _HelpTips(),
          ],
        ),
      ),
    );
  }
}

/* ───────────────── Small Tips / Helper ───────────────── */

class _HelpTips extends StatelessWidget {
  const _HelpTips();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Trouble receiving the email?', style: style),
        const SizedBox(height: 4),
        Text('• Check your spam/junk folder', style: style),
        Text('• Ensure the email is spelled correctly', style: style),
        Text('• Try again after a few seconds', style: style),
      ],
    );
  }
}
