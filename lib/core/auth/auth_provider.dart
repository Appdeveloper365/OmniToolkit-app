/// FILE: lib/core/auth/auth_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_model.dart';

class AuthState {
  const AuthState({
    this.userModel,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserModel? userModel;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    UserModel? Function()? userModel,
    bool? isAuthenticated,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return AuthState(
      userModel: userModel != null ? userModel() : this.userModel,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

final appAuthProvider = NotifierProvider<AppAuthNotifier, AuthState>(AppAuthNotifier.new);

class AppAuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Default fallback mock user for desktop/offline mode so monetization doesn't break offline builds
    final now = DateTime.now();
    final trialUser = UserModel(
      uid: 'offline_local_user',
      email: 'guest@omnitoolkit.app',
      createdAt: now,
      paymentStatus: 'unpaid',
      hasLifetimeAccess: false,
      trialStartDate: now,
      trialExpiresAt: now.add(const Duration(days: 7)),
    );

    return AuthState(
      userModel: trialUser,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  void signInMock() {
    final now = DateTime.now();
    state = state.copyWith(
      isAuthenticated: true,
      userModel: () => UserModel(
        uid: 'user_123',
        email: 'user@example.com',
        createdAt: now,
        paymentStatus: 'unpaid',
        hasLifetimeAccess: false,
        trialStartDate: now,
        trialExpiresAt: now.add(const Duration(days: 7)),
      ),
    );
  }

  void acceptDisclaimer() {
    if (state.userModel == null) return;
    final u = state.userModel!;
    state = state.copyWith(
      userModel: () => UserModel(
        uid: u.uid,
        email: u.email,
        createdAt: u.createdAt,
        paymentStatus: u.paymentStatus,
        hasLifetimeAccess: u.hasLifetimeAccess,
        trialStartDate: u.trialStartDate,
        trialExpiresAt: u.trialExpiresAt,
        purchaseDate: u.purchaseDate,
        stripeCustomerId: u.stripeCustomerId,
        stripeSessionId: u.stripeSessionId,
        disclaimerAccepted: true,
        disclaimerAcceptedAt: DateTime.now(),
      ),
    );
  }

  void grantLifetimeAccessMock() {
    if (state.userModel == null) return;
    final u = state.userModel!;
    state = state.copyWith(
      userModel: () => UserModel(
        uid: u.uid,
        email: u.email,
        createdAt: u.createdAt,
        paymentStatus: 'paid',
        hasLifetimeAccess: true,
        trialStartDate: u.trialStartDate,
        trialExpiresAt: u.trialExpiresAt,
        purchaseDate: DateTime.now(),
        disclaimerAccepted: true,
        disclaimerAcceptedAt: u.disclaimerAcceptedAt ?? DateTime.now(),
      ),
    );
  }

  void signOut() {
    state = state.copyWith(
      isAuthenticated: false,
      userModel: () => null,
    );
  }
}
