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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(appAuthProvider);
    final shouldRedirect =
        authState.isAuthenticated && authState.userModel != null && !authState.isLoading;
    if (shouldRedirect && !_redirectScheduled) {
      _redirectScheduled = true;
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
                          onPressed: authState.isLoading
                              ? null
                              : ref
                                  .read(appAuthProvider.notifier)
                                  .signInWithGoogle,
                        ),
                        if (authState.isLoading) ...[
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                        ],
                        if (authState.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            authState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
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
