import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _confirmEmailController = TextEditingController();
  final _service = MembershipService();
  MembershipState? _state;
  String? _error;
  bool _loading = true;
  bool _verificationSent = false;
  bool _callbackDetected = false;
  bool _showApp = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final pending = await _service.pendingEmail();
      if (pending != null) {
        _emailController.text = pending;
        _confirmEmailController.text = pending;
      }
      if (await _service.isVerificationLink()) {
        if (mounted) setState(() => _callbackDetected = true);
        await _completeVerification();
        return;
      }
      final user = _service.verifiedUser;
      if (user != null) {
        _emailController.text = user.email ?? _emailController.text;
        await _refreshEntitlement();
        return;
      }
      if (mounted) setState(() => _loading = false);
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'Email verification could not be completed. Please request a new link.';
        });
      }
    }
  }

  Future<void> _completeVerification() async {
    final error = _emailFormError;
    if (error != null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'Enter the same email address that received the verification link.';
        });
      }
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.completeVerification(_emailController.text);
      await _refreshEntitlement();
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = MembershipService.authErrorMessage(error);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'Email verification could not be completed. Please request a new link.';
        });
      }
    }
  }

  Future<void> _refreshEntitlement() async {
    try {
      final state = await _service.startOrRestore();
      if (!mounted) return;
      setState(() {
        _state = state;
        _showApp = state.hasAccess;
        _loading = false;
        _error = null;
      });
    } on FirebaseFunctionsException catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = MembershipService.functionsErrorMessage(error);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'We could not verify your membership right now. Please try again.';
        });
      }
    }
  }

  bool get _emailsMatch =>
      _emailController.text.isNotEmpty &&
      _confirmEmailController.text.isNotEmpty &&
      _emailController.text == _confirmEmailController.text;

  String? get _emailFormError {
    final error = MembershipService.validateEmail(_emailController.text);
    if (error != null) return error;
    if (_confirmEmailController.text.isEmpty) {
      return 'Confirm your email address.';
    }
    if (!_emailsMatch) return 'Email addresses must match exactly.';
    return null;
  }

  Future<void> _sendVerification() async {
    final error = _emailFormError;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.sendVerificationLink(_emailController.text);
      if (mounted) {
        setState(() {
          _loading = false;
          _verificationSent = true;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = MembershipService.authErrorMessage(error);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error =
              'The verification email could not be sent. Please try again.';
        });
      }
    }
  }

  void _openPurchase() => Navigator.of(context).pushNamed('/billing-notice');

  @override
  Widget build(BuildContext context) {
    if (_showApp) return const MainNavigation();
    final state = _state;
    final expired = state?.trialExpired ?? false;
    final verified = _service.verifiedUser != null;
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
                    const Icon(Icons.mark_email_read_rounded, size: 64),
                    const SizedBox(height: 16),
                    Text('Welcome to OmniToolkit',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text(
                      verified
                          ? (expired
                              ? 'Your 7-day trial has ended. Purchase Lifetime Membership to continue.'
                              : 'Checking your verified membership...')
                          : _verificationSent
                              ? 'Check your email and open the verification link. Then return here to continue.'
                              : 'Start your free 7-day trial.\n\nVerify your email to:\n• protect your trial\n• restore Lifetime Membership after reinstall\n• prevent trial abuse.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      enabled: !_loading &&
                          (!_verificationSent || _callbackDetected),
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _verificationSent
                          ? _completeVerification()
                          : _sendVerification(),
                      decoration: const InputDecoration(
                          labelText: 'Email address',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmEmailController,
                      enabled: !_loading && !_verificationSent,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      enableSuggestions: false,
                      autocorrect: false,
                      enableInteractiveSelection: false,
                      autofillHints: const <String>[],
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _sendVerification(),
                      decoration: const InputDecoration(
                        labelText: 'Confirm Email Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_verificationSent)
                      const Text(
                        'If you do not see the email within a few minutes, please check your Spam or Junk folder.',
                        textAlign: TextAlign.center,
                      ),
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 12),
                    if (state?.hasLifetimeAccess == true) ...[
                      const SizedBox(height: 12),
                      const Text('Lifetime Membership Activated',
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed:
                          _loading || (!_verificationSent && !_emailsMatch)
                              ? null
                              : (_verificationSent
                                  ? _completeVerification
                                  : _sendVerification),
                      child: Text(_loading
                          ? 'Checking...'
                          : (_verificationSent
                              ? 'I Verified My Email'
                              : 'Send Verification Link')),
                    ),
                    if (expired) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                          onPressed: _openPurchase,
                          child: const Text('Purchase Lifetime Membership')),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                        'Notes are stored locally on your device and are not backed up to the cloud. Deleting the app or clearing app data may permanently remove your notes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12)),
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
