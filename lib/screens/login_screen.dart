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
  bool _redirectScheduled = false;
  bool _signInInProgress = false;

  String _resolveAuthenticatedDestination() {
    final routeName = ModalRoute.of(context)?.settings.name;
    final uri = Uri.tryParse(routeName ?? '/login');
    final nextLocation = uri?.queryParameters['next'];
    final nextUri = nextLocation == null || nextLocation.isEmpty
        ? null
        : Uri.tryParse(nextLocation);
    final isSupportedNextRoute = nextUri != null &&
        !nextUri.hasScheme &&
        nextUri.host.isEmpty &&
        nextUri.userInfo.isEmpty &&
        !nextUri.hasFragment &&
        nextUri.path.isNotEmpty &&
        nextUri.path.startsWith('/') &&
        nextUri.path != '/login';
    return isSupportedNextRoute ? nextUri.toString() : '/';
  }

  Future<void> _handleSignIn() async {
    if (_signInInProgress) {
      debugPrint('[LoginScreen] Sign-in already in progress, ignoring duplicate click');
      return;
    }

    _signInInProgress = true;
    debugPrint('[LoginScreen] Starting sign-in process');

    try {
      // Call the sign-in method
      await ref.read(appAuthProvider.notifier).signInWithGoogle();


    } catch (e) {
      debugPrint('[LoginScreen] Error during sign-in: $e');
      _signInInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(appAuthProvider);
    
    // Reset sign-in flag if loading is false (sign-in completed or failed)
    if (!authState.isLoading) {
      _signInInProgress = false;
    }
    
    final shouldRedirect =
        authState.isAuthenticated && authState.userModel != null && !authState.isLoading;
    if (shouldRedirect && !_redirectScheduled) {
      _redirectScheduled = true;
      debugPrint('[LoginScreen] Redirecting authenticated user to dashboard');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, _resolveAuthenticatedDestination());
      });
    } else if (!shouldRedirect) {
      _redirectScheduled = false;
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Card(
                  key: ValueKey(authState.isLoading),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.lock_person_rounded,
                            size: 56, color: theme.colorScheme.primary),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome to OmniToolkit',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                                      : const Color(0xFFC7D2FE)),
                            ),
                            child: const Text(
                              BuildConfig.storeComplianceLockMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  height: 1.4),
                            ),
                          )
                        else
                          Text(
                            'Sign in with Google to start your 7-day free trial.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon:
                              const Icon(Icons.g_mobiledata_rounded, size: 28),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          onPressed: authState.isLoading ? null : _handleSignIn,
                        ),
                        if (authState.isLoading) ...[
                          const SizedBox(height: 16),
                          const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text(
                                  'Signing in...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If this takes longer than 30 seconds, please check your connection.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                        if (authState.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: theme.colorScheme.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authState.errorMessage!,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!authState.isLoading) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.error,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      onPressed: _handleSignIn,
                                      child: Text(
                                        'Try Again',
                                        style: TextStyle(
                                          color: theme.colorScheme.onError,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
      ),
    );
  }
}
