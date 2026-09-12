/// FILE: lib/core/purchase/email_verify_dialog.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../membership/membership_service.dart';
import '../navigation/main_navigation.dart';
import 'entitlement_watcher.dart';
import 'pending_purchase_action.dart';
import 'staged_loader.dart';

enum _EmailDialogState { input, checking, alreadyOwned, waiting }

/// Prompts for (and confirms) an email address, verifies whether it is
/// already entitled via StagedLoader (UI protection layer), sends a Firebase
/// email-link verification message, and monitors purchase completion with
/// automatic polling and manual "Check Now" fallbacks.
class EmailVerifyDialog {
  static Future<void> requestVerification(
    BuildContext context,
    PendingPurchaseAction action, {
    String? prefill,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _EmailVerifyDialogBody(
        rootContext: context,
        action: action,
        prefill: prefill,
      ),
    );
  }
}

class _EmailVerifyDialogBody extends StatefulWidget {
  const _EmailVerifyDialogBody({
    required this.rootContext,
    required this.action,
    this.prefill,
  });

  final BuildContext rootContext;
  final PendingPurchaseAction action;
  final String? prefill;

  @override
  State<_EmailVerifyDialogBody> createState() => _EmailVerifyDialogBodyState();
}

class _EmailVerifyDialogBodyState extends State<_EmailVerifyDialogBody> {
  final _emailController = TextEditingController();
  final _confirmController = TextEditingController();
  _EmailDialogState _state = _EmailDialogState.input;
  String _checkedEmail = '';
  String? _error;
  String? _waitingNote;
  bool _isCheckingNow = false;
  Timer? _autoRedirectTimer;

  @override
  void initState() {
    super.initState();
    if (widget.prefill != null && widget.prefill!.isNotEmpty) {
      _emailController.text = widget.prefill!;
      _confirmController.text = widget.prefill!;
    }
  }

  @override
  void dispose() {
    _autoRedirectTimer?.cancel();
    _emailController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _emailsMatch {
    final a = _emailController.text.trim().toLowerCase();
    final b = _confirmController.text.trim().toLowerCase();
    return a.isNotEmpty && a.contains('@') && a == b;
  }

  Future<void> _submitAndCheck() async {
    if (!_emailsMatch || _state == _EmailDialogState.checking) return;
    final email = _emailController.text.trim().toLowerCase();

    setState(() {
      _checkedEmail = email;
      _state = _EmailDialogState.checking;
      _error = null;
    });

    // DUPLICATE PURCHASE PROTECTION (Client Layer):
    // Check if this email already owns Lifetime Access before sending an email link.
    try {
      final state = await MembershipService().lookupEntitlementByEmail(email);
      if (!mounted) return;
      if (state.hasLifetimeAccess) {
        setState(() => _state = _EmailDialogState.alreadyOwned);
        _autoRedirectTimer?.cancel();
        _autoRedirectTimer = Timer(const Duration(seconds: 1), () {
          if (mounted) {
            _openRadioDirectory();
          }
        });
        return;
      }
    } catch (_) {
      // Lookup error (e.g. offline/transient); proceed to send link.
    }

    // Email is not yet entitled: send verification link and transition to waiting.
    try {
      await PendingPurchaseActionStore.set(widget.action);
      await MembershipService().sendVerificationLink(email);
      if (!mounted) return;

      // Start background polling to auto-unlock when webhook fulfills
      EntitlementWatcher.instance.watch(
        email,
        onUnlocked: () {
          if (mounted && Navigator.canPop(context)) {
            _openRadioDirectory();
          }
        },
      );

      setState(() => _state = _EmailDialogState.waiting);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = MembershipService.authErrorMessage(error);
        _state = _EmailDialogState.input;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'The verification email could not be sent. Please try again.';
        _state = _EmailDialogState.input;
      });
    }
  }

  Future<void> _checkNow() async {
    if (_isCheckingNow) return;
    setState(() {
      _isCheckingNow = true;
      _waitingNote = 'Checking your purchase...';
    });

    try {
      final unlocked = await EntitlementWatcher.instance.checkNow(
        emailOverride: _checkedEmail,
      );
      if (!mounted) return;
      if (unlocked) {
        _openRadioDirectory();
      } else {
        setState(() {
          _isCheckingNow = false;
          _waitingNote =
              'Not confirmed yet. If you just completed payment, wait a '
              'few seconds and tap Check Now again.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCheckingNow = false;
        _waitingNote = 'Network error checking status. Please try again.';
      });
    }
  }

  void _openRadioDirectory() {
    _autoRedirectTimer?.cancel();
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    final root = widget.rootContext;
    if (root.mounted) {
      Navigator.of(root).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(initialIndex: 2),
        ),
        (route) => false,
      );
      ScaffoldMessenger.of(root).showSnackBar(const SnackBar(
        content: Text(
          'Lifetime Membership Activated. World Radio Explorer is unlocked.',
        ),
      ));
    }
  }

  String _title() {
    switch (_state) {
      case _EmailDialogState.alreadyOwned:
        return '✅ Lifetime Membership Verified';
      case _EmailDialogState.checking:
        return 'Checking Membership...';
      case _EmailDialogState.waiting:
        return 'Check your email';
      case _EmailDialogState.input:
        return 'Unlock Radio Directory';
    }
  }

  Widget _content() {
    switch (_state) {
      case _EmailDialogState.input:
        return Column(
          key: const ValueKey('input'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email to continue. We will check your membership '
              'before any payment.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'you@example.com',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              decoration: const InputDecoration(
                labelText: 'Confirm Email Address',
                hintText: 'Re-enter your email',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              contextMenuBuilder: (context, editableTextState) {
                return const SizedBox.shrink();
              },
            ),
            if (_confirmController.text.isNotEmpty && !_emailsMatch) ...[
              const SizedBox(height: 8),
              const Text(
                'Email addresses must match exactly.',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'If you do not see the email within a few minutes, please '
              'check your Spam or Junk folder.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );

      case _EmailDialogState.checking:
        return const StagedLoader(key: ValueKey('checking'));

      case _EmailDialogState.alreadyOwned:
        return const Column(
          key: ValueKey('owned'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.verified_rounded, color: Colors.green, size: 56),
            SizedBox(height: 16),
            Text(
              'This email already owns Lifetime Access.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            SizedBox(height: 8),
            Text(
              'World Radio Explorer has been unlocked.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Opening World Radio Explorer...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(),
          ],
        );

      case _EmailDialogState.waiting:
        return Column(
          key: const ValueKey('waiting'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We sent a confirmation link to $_checkedEmail.\n\n'
              'Tap it to proceed to secure checkout. This app will unlock '
              'automatically the moment your purchase completes.\n\n'
              'If you do not see the email within a few minutes, please '
              'check your Spam or Junk folder.\n\n'
              'Already completed payment? Tap "Check Now" below.',
            ),
            if (_waitingNote != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_isCheckingNow)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (_isCheckingNow) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _waitingNote!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
    }
  }

  List<Widget> _actions() {
    switch (_state) {
      case _EmailDialogState.input:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _emailsMatch ? _submitAndCheck : null,
            child: const Text('Check Membership & Continue'),
          ),
        ];

      case _EmailDialogState.checking:
        return const [];

      case _EmailDialogState.alreadyOwned:
        return [
          FilledButton(
            onPressed: _openRadioDirectory,
            child: const Text('Open Radio Directory'),
          ),
          OutlinedButton(
            onPressed: _openRadioDirectory,
            child: const Text('Return To Radio Directory'),
          ),
        ];

      case _EmailDialogState.waiting:
        return [
          TextButton(
            onPressed: _isCheckingNow ? null : () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: _isCheckingNow ? null : _checkNow,
            child: const Text("I've paid — Check Now"),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title()),
      content: AnimatedSize(
        duration: const Duration(milliseconds: 150),
        child: SingleChildScrollView(
          child: _content(),
        ),
      ),
      actions: _actions(),
    );
  }
}