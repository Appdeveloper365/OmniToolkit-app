import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PremiumMembershipScreen extends StatelessWidget {
  const PremiumMembershipScreen({super.key, String? signedInEmail})
      : _signedInEmail = signedInEmail;

  final String? _signedInEmail;

  String? _currentEmail() {
    try {
      return FirebaseAuth.instance.currentUser?.email;
    } catch (_) {
      // Firebase not initialized (widget tests, previews): treat as signed out.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedInEmail = (_signedInEmail ?? _currentEmail() ?? '')
        .trim()
        .toLowerCase();
    final signedIn = signedInEmail.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Membership')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.devices_rounded),
              title: const Text(
                'Active Devices',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                signedIn
                    ? 'Manage the devices linked to your lifetime membership.'
                    : 'Sign in with your verified purchase email to manage devices.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushNamed(
                context,
                signedIn ? '/active-devices' : '/membership-status',
              ),
            ),
          ),
          if (!signedIn) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium_rounded),
                title: const Text('Verify Membership'),
                subtitle: const Text('Open Membership Status to verify access.'),
                onTap: () => Navigator.pushNamed(context, '/membership-status'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
