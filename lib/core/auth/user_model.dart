/// FILE: lib/core/auth/user_model.dart

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.paymentStatus,
    required this.hasLifetimeAccess,
    required this.trialStartDate,
    required this.trialExpiresAt,
    this.purchaseDate,
    this.stripeCustomerId,
    this.stripeSessionId,
    this.disclaimerAccepted = false,
    this.disclaimerAcceptedAt,
  });

  final String uid;
  final String email;
  final DateTime createdAt;
  final String paymentStatus; // "unpaid" | "paid"
  final bool hasLifetimeAccess;
  final DateTime trialStartDate;
  final DateTime trialExpiresAt;
  final DateTime? purchaseDate;
  final String? stripeCustomerId;
  final String? stripeSessionId;
  final bool disclaimerAccepted;
  final DateTime? disclaimerAcceptedAt;

  bool get isPaid => paymentStatus == 'paid' || hasLifetimeAccess;

  bool get isTrialActive => DateTime.now().isBefore(trialExpiresAt);

  bool get isEntitled => isPaid || isTrialActive;

  int get remainingTrialDays {
    if (isPaid) return 0;
    final diff = trialExpiresAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff + 1;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      createdAt: _parseDate(map['createdAt']),
      paymentStatus: map['paymentStatus'] as String? ?? 'unpaid',
      hasLifetimeAccess: map['hasLifetimeAccess'] as bool? ?? false,
      trialStartDate: _parseDate(map['trialStartDate']),
      trialExpiresAt: _parseDate(map['trialExpiresAt']),
      purchaseDate: map['purchaseDate'] != null ? _parseDate(map['purchaseDate']) : null,
      stripeCustomerId: map['stripeCustomerId'] as String?,
      stripeSessionId: map['stripeSessionId'] as String?,
      disclaimerAccepted: map['disclaimerAccepted'] as bool? ?? false,
      disclaimerAcceptedAt: map['disclaimerAcceptedAt'] != null ? _parseDate(map['disclaimerAcceptedAt']) : null,
    );
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
        'paymentStatus': paymentStatus,
        'hasLifetimeAccess': hasLifetimeAccess,
        'trialStartDate': trialStartDate.toIso8601String(),
        'trialExpiresAt': trialExpiresAt.toIso8601String(),
        if (purchaseDate != null) 'purchaseDate': purchaseDate!.toIso8601String(),
        if (stripeCustomerId != null) 'stripeCustomerId': stripeCustomerId,
        if (stripeSessionId != null) 'stripeSessionId': stripeSessionId,
        'disclaimerAccepted': disclaimerAccepted,
        if (disclaimerAcceptedAt != null) 'disclaimerAcceptedAt': disclaimerAcceptedAt!.toIso8601String(),
      };
}
