/// FILE: lib/core/purchase/email_verify_dialog.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../membership/membership_service.dart';
import 'pending_purchase_action.dart';
import 'radio_launch_controller.dart';

/// Prompts for (and confirms) an email address, sends a Firebase email-link
/// verification message, and records which purchase action (Unlock or
/// Restore) to resume once the user returns through the verification link.
class EmailVerifyDialog {
  static Future<void> requestVerification(
    BuildContext context,
    PendingPurchaseAction action,
  ) async {
    final emailController = TextEditingController();
    final confirmController = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final email = emailController.text.trim();
          final confirm = confirmController.text.trim();
          final matches = email.isNotEmpty && email == confirm;
          return AlertDialog(
            title: const Text('Verify your email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OmniToolkit is free to use. World Radio Explorer requires '
                  'a one-time Lifetime Access purchase.\n\n'
                  'Verify your email to:\n'
                  '\u2022 link Lifetime Access to your account\n'
                  '\u2022 restore Lifetime Membership after reinstall\n'
                  '\u2022 prevent unauthorized access',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Email Address',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  contextMenuBuilder: (context, editableTextState) {
                    // Disable paste in the confirm field so the user must
                    // type the address by hand, catching typos.
                    return const SizedBox.shrink();
                  },
                ),
                if (email.isNotEmpty && confirm.isNotEmpty && !matches) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Email addresses must match exactly.',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'If you do not see the email within a few minutes, please '
                  'check your Spam or Junk folder.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: matches
                    ? () => Navigator.pop(dialogContext, email)
                    : null,
                child: const Text('Send Verification Link'),
              ),
            ],
          );
        },
      ),
    );

    if (email == null || email.isEmpty) return;

    try {
      // DUPLICATE PURCHASE PROTECTION (Client Layer 1):
      // Check if this email already owns Lifetime Access before sending an email link.
      try {
        final state = await MembershipService().lookupEntitlementByEmail(email);
        if (state.hasLifetimeAccess) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'Lifetime Membership Activated. World Radio Explorer is unlocked.',
              ),
            ));
            RadioLaunchController.requestOpen();
          }
          return;
        }
      } catch (_) {
        // Continue to send verification link if lookup had a temporary network failure.
      }

      await PendingPurchaseActionStore.set(action);
      await MembershipService().sendVerificationLink(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Check your email and open the verification link to continue. '
            'If you do not see it within a few minutes, check your Spam or '
            'Junk folder.',
          ),
          duration: Duration(seconds: 6),
        ));
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(MembershipService.authErrorMessage(error))),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'The verification email could not be sent. Please try again.',
          ),
        ));
      }
    }
  }
}