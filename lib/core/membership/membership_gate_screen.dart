import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../core/navigation/main_navigation.dart';
import '../membership/membership_service.dart';

class MembershipGateScreen extends StatefulWidget {
  const MembershipGateScreen({super.key});

  @override
  State<MembershipGateScreen> createState() => _MembershipGateScreenState();
}

class _MembershipGateScreenState extends State<MembershipGateScreen> {
  final _emailController = TextEditingController();
  final _service = MembershipService();
  MembershipState? _state;
  String? _error;
  bool _loading = true;
  bool _showApp = false;

  @override
  void initState() {
    super.initState();
    _restoreCachedState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _restoreCachedState() async {
    final cached = await _service.cached();
    if (!mounted) return;
    if (cached != null) {
      _emailController.text = cached.email;
      setState(() {
        _state = cached;
        _showApp = cached.hasAccess;
        _loading = false;
      });
      _refresh(cached.email);
      return;
    }
    setState(() => _loading = false);
  }

  Future<void> _refresh(String email) async {
    try {
      final state = await _service.startOrRestore(email);
      if (!mounted) return;
      setState(() {
        _state = state;
        _showApp = state.hasAccess;
        _loading = false;
        _error = null;
      });
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message ?? 'We could not verify your trial right now.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'We could not verify your trial right now. Please try again. ($error)';
      });
    }
  }

  Future<void> _submitEmail() async {
    final error = MembershipService.validateEmail(_emailController.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await _refresh(_emailController.text);
  }

  void _openPurchase() {
    Navigator.of(context).pushNamed('/billing-notice');
  }

  @override
  Widget build(BuildContext context) {
    if (_showApp && _state?.hasLifetimeAccess != true) return const MainNavigation();
    final state = _state;
    final expired = state?.trialExpired ?? false;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.workspace_premium_rounded, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to OmniToolkit',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state == null
                          ? 'Enter your email to start your one-time 7-day trial.'
                          : expired
                              ? 'Your 7-day trial has ended. Purchase Lifetime Membership to continue.'
                              : 'Your membership could not be restored yet.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitEmail(),
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_error != null)
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    if (state?.hasLifetimeAccess == true) ...[
                      const SizedBox(height: 12),
                      const Text('Lifetime Membership Activated', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => setState(() => _showApp = true),
                        child: const Text('Continue to OmniToolkit'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading ? null : _submitEmail,
                      child: Text(_loading ? 'Checking...' : state == null ? 'Start 7-Day Trial' : 'Restore Access'),
                    ),
                    if (expired) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _openPurchase, child: const Text('Purchase Lifetime Membership')),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Your email is used only to prevent repeated trials and restore purchases. Notes remain stored locally on this device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
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
