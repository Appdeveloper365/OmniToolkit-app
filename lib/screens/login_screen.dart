/// FILE: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_provider.dart';
import '../core/config/build_config.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  bool _magicLinkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendMagicLink() {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _magicLinkSent = true);
    ref.read(appAuthProvider.notifier).signInMock();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.lock_person_rounded, size: 56, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to OmniToolkit',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      if (BuildConfig.isStoreBuild)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF1E1B4B)
                                : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF4338CA)
                                  : const Color(0xFFC7D2FE),
                            ),
                          ),
                          child: const Text(
                            BuildConfig.storeComplianceLockMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Sign in to start your 7-day free trial.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),

                      const SizedBox(height: 24),

                      // Google Sign In
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onPressed: () {
                          ref.read(appAuthProvider.notifier).signInMock();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),

                      const SizedBox(height: 20),
                      Row(children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ),
                        const Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 20),

                      // Email Magic Link
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text(
                          'Send Magic Link',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onPressed: _sendMagicLink,
                      ),

                      if (_magicLinkSent) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            '✨ Magic link sent! Check your inbox to sign in.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
