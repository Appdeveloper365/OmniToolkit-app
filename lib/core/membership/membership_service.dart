import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'browser_location.dart';

class EmailLinkDiagnostics {
  String currentUrl = '';
  String windowLocationHref = '';
  String actionCode = 'not checked';
  String isSignInWithEmailLink = 'not checked';
  String emailUsed = 'not checked';
  String signInWithEmailLinkResult = 'not started';
  String currentUserAfterSignIn = 'not checked';
  String userEmailVerified = 'not checked';
  String userRefreshResult = 'not started';
  String trialCreationResult = 'not started';
  String firstFailure = 'none recorded';

  Map<String, String> get values => {
        'Current URL': currentUrl,
        'window.location.href': windowLocationHref,
        'Firebase actionCode': actionCode,
        'isSignInWithEmailLink': isSignInWithEmailLink,
        'Email used for sign-in': emailUsed,
        'signInWithEmailLink result': signInWithEmailLinkResult,
        'currentUser after sign-in': currentUserAfterSignIn,
        'user.emailVerified': userEmailVerified,
        'User refresh result': userRefreshResult,
        'Trial creation result': trialCreationResult,
        'First failure': firstFailure,
      };
}

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

  final diagnostics = EmailLinkDiagnostics();

  void _log(String message) => debugPrint('[EmailLinkDiagnostics] $message');

  void _fail(String stage, Object error) {
    if (diagnostics.firstFailure == 'none recorded') {
      diagnostics.firstFailure = '$stage: ${error.runtimeType}';
    }
    _log('$stage failed (${error.runtimeType})');
  }

  String _maskedActionCode(Uri uri) {
    final code =
        uri.queryParameters['oobCode'] ?? uri.queryParameters['actionCode'];
    if (code == null || code.isEmpty) return 'missing';
    if (code.length <= 8) return 'present (masked)';
    return '${code.substring(0, 4)}...${code.substring(code.length - 4)} (masked)';
  }

  Future<MembershipState?> cached() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return MembershipState.fromCache(prefs);
    } on StateError {
      return null;
    }
  }

  /// Immediate "Verify Purchase" lookup by email -- deliberately requires no
  /// Firebase email-link verification. Used by the Restore Purchase dialog
  /// so a returning customer can confirm Lifetime Access with a single tap,
  /// before (or entirely without) proving ownership of the email via a
  /// verification link. If a Lifetime Membership is found, the result is
  /// cached locally so RadioAccessGate unlocks immediately.
  Future<MembershipState> lookupEntitlementByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || !normalized.contains('@')) {
      throw ArgumentError('A valid email address is required.');
    }
    final result = await FirebaseFunctions.instance
        .httpsCallable('checkEntitlementByEmail')
        .call<Map<String, dynamic>>({'email': normalized});
    final state = MembershipState.fromData(result.data);
    if (state.hasLifetimeAccess) {
      await _save(state);
    }
    return state;
  }

  String? extractEmailFromLink() {
    final link = currentEmailLink;
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    final emailParam = uri.queryParameters['email'];
    if (emailParam != null && emailParam.trim().isNotEmpty) {
      return emailParam.trim().toLowerCase();
    }
    if (uri.fragment.isNotEmpty) {
      final fragmentUri = Uri.tryParse('http://dummy/?${uri.fragment}');
      final fEmail = fragmentUri?.queryParameters['email'];
      if (fEmail != null && fEmail.trim().isNotEmpty) {
        return fEmail.trim().toLowerCase();
      }
    }
    return null;
  }

  Future<String?> pendingEmail() async {
    final fromLink = extractEmailFromLink();
    if (fromLink != null && fromLink.isNotEmpty) return fromLink;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingEmailKey);
  }

  Future<void> sendVerificationLink(String email) async {
    final normalized = email.trim().toLowerCase();
    final continueUrlWithEmail =
        '$continueUrl?email=${Uri.encodeComponent(normalized)}';
    final settings = ActionCodeSettings(
      url: continueUrlWithEmail,
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
    diagnostics.currentUrl = Uri.base.toString();
    diagnostics.windowLocationHref = currentEmailLink;
    final uri = Uri.tryParse(currentEmailLink);
    diagnostics.actionCode =
        uri == null ? 'invalid URL' : _maskedActionCode(uri);
    _log('currentUrl=${diagnostics.currentUrl}');
    _log('window.location.href=${diagnostics.windowLocationHref}');
    _log('Firebase actionCode=${diagnostics.actionCode}');
    if (!kIsWeb || Firebase.apps.isEmpty) {
      diagnostics.isSignInWithEmailLink = 'false (web/Firebase unavailable)';
      return false;
    }
    try {
      final result =
          FirebaseAuth.instance.isSignInWithEmailLink(currentEmailLink);
      diagnostics.isSignInWithEmailLink = result.toString();
      _log('isSignInWithEmailLink=$result');
      return result;
    } catch (error) {
      diagnostics.isSignInWithEmailLink = 'error';
      _fail('isSignInWithEmailLink', error);
      rethrow;
    }
  }

  Future<UserCredential> completeVerification(String email) async {
    final normalized = email.trim().toLowerCase();
    diagnostics.emailUsed = normalized.isEmpty ? 'missing' : normalized;
    _log('email used for sign-in=${diagnostics.emailUsed}');
    if (normalized.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Enter the email address that received the verification link.',
      );
    }
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailLink(
        email: normalized,
        emailLink: currentEmailLink,
      );
      diagnostics.signInWithEmailLinkResult = 'success';
      _log('signInWithEmailLink result=success');
      final user = credential.user;
      diagnostics.currentUserAfterSignIn = user?.email ?? 'null';
      diagnostics.userEmailVerified = user?.emailVerified.toString() ?? 'null';
      _log('currentUser after sign-in=${diagnostics.currentUserAfterSignIn}');
      _log('user.emailVerified=${diagnostics.userEmailVerified}');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingEmailKey);
      try {
        await user?.reload();
        diagnostics.userRefreshResult = 'success';
        _log('user refresh result=success');
        final refreshedUser = FirebaseAuth.instance.currentUser;
        await refreshedUser?.getIdToken(true);
        _log('ID token refresh result=success');
      } catch (error) {
        diagnostics.userRefreshResult = 'failed (${error.runtimeType})';
        _fail('user refresh', error);
        rethrow;
      }
      final refreshedUser = FirebaseAuth.instance.currentUser;
      diagnostics.currentUserAfterSignIn = refreshedUser?.email ?? 'null';
      diagnostics.userEmailVerified =
          refreshedUser?.emailVerified.toString() ?? 'null';
      _log('currentUser after refresh=${diagnostics.currentUserAfterSignIn}');
      _log('user.emailVerified after refresh=${diagnostics.userEmailVerified}');
      return credential;
    } catch (error) {
      diagnostics.signInWithEmailLinkResult = 'failed (${error.runtimeType})';
      _fail('signInWithEmailLink', error);
      rethrow;
    }
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

  Future<User?> refreshVerifiedUser() async {
    if (Firebase.apps.isEmpty) return null;
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    await user.reload();
    user = FirebaseAuth.instance.currentUser;
    if (user?.emailVerified == true) {
      await user!.getIdToken(true);
      return user;
    }
    return null;
  }

  Future<MembershipState> startOrRestore() async {
    final user = verifiedUser;
    if (user == null || user.email == null) {
      throw StateError(
          'Verify your email before starting or restoring access.');
    }
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('startOrRestoreTrial')
          .call<Map<String, dynamic>>();
      final state = MembershipState.fromData(result.data);
      diagnostics.trialCreationResult =
          'success (trialActive=${state.trialActive}, lifetime=${state.hasLifetimeAccess})';
      _log('trial creation result=${diagnostics.trialCreationResult}');
      await _save(state);
      return state;
    } catch (error) {
      diagnostics.trialCreationResult = 'failed (${error.runtimeType})';
      _fail('trial creation', error);
      rethrow;
    }
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
