import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembershipState {
  const MembershipState({
    required this.email,
    required this.hasLifetimeAccess,
    required this.trialActive,
    this.trialStartDate,
    this.trialEndDate,
    this.purchaseDate,
  });

  final String email;
  final bool hasLifetimeAccess;
  final bool trialActive;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? purchaseDate;

  bool get hasAccess => hasLifetimeAccess || trialActive;
  bool get trialExpired => !hasLifetimeAccess && !trialActive;

  factory MembershipState.fromData(Map<String, dynamic> data) {
    DateTime? parseDate(Object? value) =>
        value is String ? DateTime.tryParse(value)?.toLocal() : null;
    return MembershipState(
      email: (data['email'] as String? ?? '').trim().toLowerCase(),
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
    final end = DateTime.tryParse(prefs.getString('membership.trialEndDate') ?? '');
    final lifetime = prefs.getBool('membership.hasLifetimeAccess') ?? false;
    return MembershipState(
      email: email,
      hasLifetimeAccess: lifetime,
      trialActive: lifetime || (end != null && end.isAfter(DateTime.now())),
      trialEndDate: end,
      trialStartDate: DateTime.tryParse(prefs.getString('membership.trialStartDate') ?? ''),
      purchaseDate: DateTime.tryParse(prefs.getString('membership.purchaseDate') ?? ''),
    );
  }
}

class MembershipService {
  Future<MembershipState?> cached() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return MembershipState.fromCache(prefs);
    } on StateError {
      return null;
    }
  }

  Future<MembershipState> startOrRestore(String email) async {
    final normalized = email.trim().toLowerCase();
    final result = await FirebaseFunctions.instance
        .httpsCallable('startOrRestoreTrial')
        .call<Map<String, dynamic>>({'email': normalized});
    final state = MembershipState.fromData(result.data);
    await _save(state);
    return state;
  }

  Future<void> _save(MembershipState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('membership.email', state.email);
    await prefs.setBool('membership.hasLifetimeAccess', state.hasLifetimeAccess);
    await _setDate(prefs, 'membership.trialStartDate', state.trialStartDate);
    await _setDate(prefs, 'membership.trialEndDate', state.trialEndDate);
    await _setDate(prefs, 'membership.purchaseDate', state.purchaseDate);
  }

  Future<void> _setDate(SharedPreferences prefs, String key, DateTime? value) async {
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value.toIso8601String());
    }
  }

  static String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Enter your email address to start your trial.';
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }
}
