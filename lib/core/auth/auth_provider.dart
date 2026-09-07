import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'user_model.dart';

class AuthState {
  const AuthState({
    this.userModel,
    this.isAuthenticated = false,
    this.isLoading = true,
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

final appAuthProvider =
    NotifierProvider<AppAuthNotifier, AuthState>(AppAuthNotifier.new);

class AppAuthNotifier extends Notifier<AuthState> {
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  AuthState build() {
    if (kIsWeb) {
      _auth.setPersistence(Persistence.LOCAL);
    }
    _authSubscription = _auth.authStateChanges().listen(_handleFirebaseUser);
    ref.onDispose(() {
      _authSubscription?.cancel();
      _userSubscription?.cancel();
    });

    return const AuthState(isLoading: true);
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        await _auth.signInWithProvider(provider);
        return;
      }

      final googleUser =
          await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false, errorMessage: () => null);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () =>
            error.message ?? 'Google sign-in failed. Please try again.',
      );
    } on FirebaseException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () =>
            error.message ?? 'Authentication service is unavailable.',
      );
    }
  }

  Future<void> acceptDisclaimer() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      state = state.copyWith(
          errorMessage: () => 'Please sign in before purchasing.');
      return;
    }

    try {
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'disclaimerAccepted': true,
        'disclaimerAcceptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      state = state.copyWith(
        errorMessage: () =>
            error.message ?? 'Could not save purchase acknowledgement.',
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    await _auth.signOut();
  }

  Future<void> _handleFirebaseUser(User? firebaseUser) async {
    await _userSubscription?.cancel();
    _userSubscription = null;

    if (firebaseUser == null) {
      state = const AuthState(isAuthenticated: false, isLoading: false);
      return;
    }

    state = state.copyWith(
        isAuthenticated: true, isLoading: true, errorMessage: () => null);
    try {
      await _ensureUserDocument(firebaseUser);
      _userSubscription = _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen(
        (snapshot) {
          final data = snapshot.data();
          if (data == null) {
            state = state.copyWith(
              userModel: () => null,
              isAuthenticated: true,
              isLoading: false,
              errorMessage: () =>
                  'Account record is unavailable. Please sign in again.',
            );
            return;
          }

          state = state.copyWith(
            userModel: () => UserModel.fromMap(data, firebaseUser.uid),
            isAuthenticated: true,
            isLoading: false,
            errorMessage: () => null,
          );
        },
        onError: (Object error) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () =>
                'Could not load account entitlement. Please check your connection.',
          );
        },
      );
    } on FirebaseException catch (error) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        errorMessage: () => error.message ?? 'Could not prepare your account.',
      );
    }
  }

  Future<void> _ensureUserDocument(User firebaseUser) async {
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (snapshot.exists) {
        transaction.set(
          userRef,
          {
            'uid': firebaseUser.uid,
            'email': firebaseUser.email ?? '',
            'lastLoginAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return;
      }

      final now = Timestamp.now();
      final trialExpiresAt =
          Timestamp.fromDate(now.toDate().add(const Duration(days: 7)));
      transaction.set(userRef, {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'createdAt': now,
        'trialStartDate': now,
        'trialExpiresAt': trialExpiresAt,
        'paymentStatus': 'unpaid',
        'hasLifetimeAccess': false,
        'premium_active': false,
        'purchaseDate': null,
        'stripeCustomerId': null,
        'stripeSessionId': null,
        'disclaimerAccepted': false,
        'disclaimerAcceptedAt': null,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
