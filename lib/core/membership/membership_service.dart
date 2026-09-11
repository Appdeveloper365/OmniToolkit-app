import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'browser_location.dart';

class MembershipState {
  const MembershipState({
    required this.email,
    required this.emailVerified,
    required this.hasLifetimeAccess,
    required this.trialActive,
    this.trialStartDate,
    this.trialEndDate,
    this.purchaseDate,
  });

  final String email;
  final bool emailVerified;
  final bool hasLifetimeAccess;
  final bool trialActive;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? purchaseDate;

  bool get hasAccess => emailVerified && (hasLifetimeAccess || trialActive);
  bool get trialExpired => !hasLifetimeAccess && !trialActive;

  factory MembershipState.fromData(Map<String, dynamic> data) {
    DateTime? parseDate(Object? value) =>
        value is String ? DateTime.tryParse(value)?.toLocal() : null;
    return MembershipState(
      email: (data['email'] as String? ?? '').trim().toLowerCase(),
      emailVerified: data['emailVerified'] as bool? ?? false,
      hasLifetimeAccess: data['hasLifetimeAccess'] as bool? ?? false,
      trialActive: data['trialActive'] as bool? ?? false,
      trialStartDate: parseDate(data['trialStartDate']),
      trialEndDate: parseDate(data['trialEndDate']),
      purchaseDate: parseDate(data['purchaseDate']),
    );
  }

  factory MembershipState.fromCache(SharedPreferences prefs) {
    final email = prefs.getString('membership.email');
    if (email == null || email.isEmpty) {
      throw StateError('No cached membership email.');
    }
    final end =
        DateTime.tryParse(prefs.getString('membership.trialEndDate') ?? '');
    final lifetime = prefs.getBool('membership.hasLifetimeAccess') ?? false;
    return MembershipState(
      email: email,
      emailVerified: prefs.getBool('membership.emailVerified') ?? false,
      hasLifetimeAccess: lifetime,
      trialActive: end != null && end.isAfter(DateTime.now()),
      trialEndDate: end,
      trialStartDate:
          DateTime.tryParse(prefs.getString('membership.trialStartDate') ?? ''),
      purchaseDate:
          DateTime.tryParse(prefs.getString('membership.purchaseDate') ?? ''),
    );
  }
}

class MembershipService {
  static const _pendingEmailKey = 'membership.pendingEmail';
  static const continueUrl =
      'https://appdeveloper365.github.io/OmniToolkit-app/';

  Future<MembershipState?> cached() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return MembershipState.fromCache(prefs);
    } on StateError {
      return null;
    }
  }

  Future<String?> pendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingEmailKey);
  }

  Future<void> sendVerificationLink(String email) async {
    final normalized = email.trim().toLowerCase();
    final settings = ActionCodeSettings(
      url: continueUrl,
      handleCodeInApp: true,
    );
    await FirebaseAuth.instance.sendSignInLinkToEmail(
      email: normalized,
      actionCodeSettings: settings,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, normalized);
  }

  String get currentEmailLink => browserLocationHref;

  Future<bool> isVerificationLink() async {
    if (!kIsWeb || Firebase.apps.isEmpty) return false;
    return FirebaseAuth.instance.isSignInWithEmailLink(currentEmailLink);
  }

  Future<UserCredential> completeVerification(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Enter the email address that received the verification link.',
      );
    }
    final credential = await FirebaseAuth.instance.signInWithEmailLink(
      email: normalized,
      emailLink: currentEmailLink,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingEmailKey);
    await credential.user?.reload();
    return credential;
  }

  static String authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'missing-email':
        return 'Enter the email address that received the verification link.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-action-code':
      case 'expired-action-code':
        return 'That verification link is invalid or expired. Request a new link.';
      case 'email-already-in-use':
        return 'This email is already associated with an account. Request a new link.';
      case 'operation-not-allowed':
        return 'Email verification is temporarily unavailable. Please try again later.';
      case 'too-many-requests':
        return 'Too many verification attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'A network connection is required. Check your connection and try again.';
      default:
        return 'Email verification could not be completed. Please request a new link.';
    }
  }

  static String functionsErrorMessage(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'unauthenticated':
        return 'Verify your email before continuing.';
      case 'permission-denied':
        return 'This account is not permitted to continue yet.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'The membership service is temporarily unavailable. Please try again.';
      case 'failed-precondition':
        return 'Please complete the required acknowledgement before continuing.';
      default:
        return 'We could not verify your membership right now. Please try again.';
    }
  }

  User? get verifiedUser {
    if (Firebase.apps.isEmpty) return null;
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.emailVerified ? user : null;
  }

  Future<MembershipState> startOrRestore() async {
    final user = verifiedUser;
    if (user == null || user.email == null) {
      throw StateError(
          'Verify your email before starting or restoring access.');
    }
    final result = await FirebaseFunctions.instance
        .httpsCallable('startOrRestoreTrial')
        .call<Map<String, dynamic>>();
    final state = MembershipState.fromData(result.data);
    await _save(state);
    return state;
  }

  Future<void> _save(MembershipState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('membership.email', state.email);
    await prefs.setBool('membership.emailVerified', state.emailVerified);
    await prefs.setBool(
        'membership.hasLifetimeAccess', state.hasLifetimeAccess);
    await _setDate(prefs, 'membership.trialStartDate', state.trialStartDate);
    await _setDate(prefs, 'membership.trialEndDate', state.trialEndDate);
    await _setDate(prefs, 'membership.purchaseDate', state.purchaseDate);
  }

  Future<void> _setDate(
      SharedPreferences prefs, String key, DateTime? value) async {
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value.toIso8601String());
    }
  }

  static String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }
}
