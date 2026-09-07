import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Shown after sign-in to reconcile the authenticated account email with any
/// Lifetime Membership purchased under that same email (including purchases
/// made anonymously before sign-in). If the emails do not match, the visitor
/// is shown clear next steps rather than being silently denied access.
class EntitlementCheckScreen extends StatefulWidget {
  const EntitlementCheckScreen({super.key});

  @override
  State<EntitlementCheckScreen> createState() => _EntitlementCheckScreenState();
}

class _EntitlementCheckScreenState extends State<EntitlementCheckScreen> {
  bool _isChecking = true;
  bool _hasLifetimeAccess = false;
  bool _matched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkEntitlement();
  }

  Future<void> _checkEntitlement() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isChecking = false;
          _matched = false;
          _hasLifetimeAccess = false;
        });
        return;
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
        'checkEntitlementForSignedInUser',
      );
      final result = await callable.call<Map<String, dynamic>>();
      setState(() {
        _hasLifetimeAccess = result.data['hasLifetimeAccess'] as bool? ?? false;
        _matched = result.data['matched'] as bool? ?? false;
        _isChecking = false;
      });
    } on FirebaseFunctionsException catch (error) {
      setState(() {
        _error = error.message ?? 'Could not check membership status.';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Membership Status')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _isChecking
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Checking membership status...'),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null) ...[
                            Text(_error!, textAlign: TextAlign.center),
                          ] else if (_hasLifetimeAccess) ...[
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'Lifetime Membership is active for $email.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ] else if (_matched) ...[
                            const Icon(Icons.info_outline_rounded, size: 56),
                            const SizedBox(height: 16),
                            const Text(
                              'No active Lifetime Membership was found for this account.',
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            const Icon(Icons.mail_lock_outlined, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'We could not find a purchase for $email. '
                              'Access is linked to the billing email used at checkout. '
                              'Please sign in with the exact email address used during purchase.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 20),
                          OutlinedButton(
                            onPressed: _checkEntitlement,
                            child: const Text('Check again'),
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