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
    debugPrint('[Auth] INIT: Initializing auth provider');
    if (kIsWeb) {
      _auth.setPersistence(Persistence.LOCAL);
      debugPrint('[Auth] INIT: Set web persistence to LOCAL');
    }
    
    _authSubscription = _auth.authStateChanges().listen(
      (user) {
        debugPrint('[Auth] STREAM: Firebase auth state changed. User: ${user?.email ?? "null"}');
        _handleFirebaseUser(user);
      },
      onError: (error) {
        debugPrint('[Auth] STREAM ERROR: Auth stream error: $error');
      },
    );
    
    ref.onDispose(() {
      debugPrint('[Auth] DISPOSE: Cancelling subscriptions');
      _authSubscription?.cancel();
      _userSubscription?.cancel();
    });

    return const AuthState(isLoading: true);
  }

  Future<void> signInWithGoogle() async {
    debugPrint('[Auth] SIGNIN: Starting Google sign-in');
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    
    try {
      if (kIsWeb) {
        debugPrint('[Auth] SIGNIN: Using web flow');
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        
        debugPrint('[Auth] SIGNIN: Calling signInWithProvider');
        await _auth.signInWithProvider(provider).timeout(const Duration(seconds: 30));
        debugPrint('[Auth] SIGNIN: signInWithProvider completed successfully');
        return;
      }

      debugPrint('[Auth] SIGNIN: Using native platform flow ($defaultTargetPlatform)');
      debugPrint('[Auth] SIGNIN: Starting GoogleSignIn().signIn()');
      final googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn().timeout(const Duration(seconds: 30));
      
      if (googleUser == null) {
        debugPrint('[Auth] SIGNIN: User cancelled Google sign-in');
        state = state.copyWith(isLoading: false, errorMessage: () => null);
        return;
      }

      debugPrint('[Auth] SIGNIN: Got Google user: ${googleUser.email}');
      debugPrint('[Auth] SIGNIN: Getting Google authentication credentials');
      final googleAuth = await googleUser.authentication;
      
      debugPrint('[Auth] SIGNIN: accessToken: ${googleAuth.accessToken?.isNotEmpty == true ? "present" : "null"}');
      debugPrint('[Auth] SIGNIN: idToken: ${googleAuth.idToken?.isNotEmpty == true ? "present" : "null"}');
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      debugPrint('[Auth] SIGNIN: Signing in with Firebase using Google credential');
      await _auth.signInWithCredential(credential);
      debugPrint('[Auth] SIGNIN: Firebase sign-in completed successfully');
    } on FirebaseAuthException catch (error, st) {
      debugPrint('[Auth] ERROR: FirebaseAuthException - ${error.code}: ${error.message}');
      debugPrint('[Auth] STACKTRACE:\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: () =>
            error.message ?? 'Google sign-in failed. Please try again.',
      );
    } on FirebaseException catch (error, st) {
      debugPrint('[Auth] ERROR: FirebaseException - ${error.code}: ${error.message}');
      debugPrint('[Auth] STACKTRACE:\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: () =>
            error.message ?? 'Authentication service is unavailable.',
      );
    } on Exception catch (error, st) {
      // Catch all other exceptions (including PlatformException, network errors, etc.)
      debugPrint('[Auth] ERROR: Generic Exception - ${error.runtimeType}: $error');
      debugPrint('[Auth] STACKTRACE:\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: () =>
            'Sign-in failed: ${error.toString()}. Please check your connection and try again.',
      );
    } catch (error, st) {
      // Last resort catch for any unexpected errors
      debugPrint('[Auth] ERROR: Unexpected error - ${error.runtimeType}: $error');
      debugPrint('[Auth] STACKTRACE:\n$st');
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'An unexpected error occurred. Please try again.',
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
    debugPrint('[Auth] SIGNOUT: Starting sign out');
    if (!kIsWeb) {
      debugPrint('[Auth] SIGNOUT: Signing out from GoogleSignIn');
      await GoogleSignIn().signOut();
    }
    debugPrint('[Auth] SIGNOUT: Signing out from Firebase');
    await _auth.signOut();
    debugPrint('[Auth] SIGNOUT: Sign out completed');
  }

  Future<void> _handleFirebaseUser(User? firebaseUser) async {
    debugPrint('[Auth] HANDLE: Firebase user changed. User: ${firebaseUser?.email ?? "null"}');
    
    await _userSubscription?.cancel();
    _userSubscription = null;

    if (firebaseUser == null) {
      debugPrint('[Auth] HANDLE: No user, setting unauthenticated state');
      state = const AuthState(isAuthenticated: false, isLoading: false);
      return;
    }

    debugPrint('[Auth] HANDLE: User authenticated, setting loading=true to fetch user doc');
    state = state.copyWith(
        isAuthenticated: true, isLoading: true, errorMessage: () => null);
    
    try {
      debugPrint('[Auth] HANDLE: Ensuring user document exists for UID: ${firebaseUser.uid}');
      await _ensureUserDocument(firebaseUser);
      debugPrint('[Auth] HANDLE: User document ensured, setting up listener');
      
      _userSubscription = _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen(
        (snapshot) {
          debugPrint('[Auth] LISTENER: User document snapshot received');
          final data = snapshot.data();
          if (data == null) {
            debugPrint('[Auth] LISTENER: User document is null, setting error state');
            state = state.copyWith(
              userModel: () => null,
              isAuthenticated: true,
              isLoading: false,
              errorMessage: () =>
                  'Account record is unavailable. Please sign in again.',
            );
            return;
          }

          debugPrint('[Auth] LISTENER: User data loaded successfully, setting loading=false');
          state = state.copyWith(
            userModel: () => UserModel.fromMap(data, firebaseUser.uid),
            isAuthenticated: true,
            isLoading: false,
            errorMessage: () => null,
          );
        },
        onError: (Object error) {
          debugPrint('[Auth] LISTENER ERROR: Failed to load user document: $error');
          state = state.copyWith(
            isLoading: false,
            errorMessage: () =>
                'Could not load account. Please check your connection.',
          );
        },
      );
      debugPrint('[Auth] HANDLE: Listener set up successfully');
    } on FirebaseException catch (error, st) {
      debugPrint('[Auth] HANDLE ERROR: FirebaseException - ${error.code}: ${error.message}');
      debugPrint('[Auth] STACKTRACE:\n$st');
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        errorMessage: () => error.message ?? 'Could not prepare your account.',
      );
    } catch (error, st) {
      debugPrint('[Auth] HANDLE ERROR: Generic Exception - ${error.runtimeType}: $error');
      debugPrint('[Auth] STACKTRACE:\n$st');
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        errorMessage: () => 'Error preparing your account. Please try again.',
      );
    }
  }

  Future<void> _ensureUserDocument(User firebaseUser) async {
    debugPrint('[Auth] ENSURE_USER: Creating user document if needed for UID: ${firebaseUser.uid}');
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (snapshot.exists) {
          debugPrint('[Auth] ENSURE_USER: User document already exists, updating lastLoginAt');
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

        debugPrint('[Auth] ENSURE_USER: Creating new user document');
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
        debugPrint('[Auth] ENSURE_USER: New user document created successfully');
      });
    } catch (error, st) {
      debugPrint('[Auth] ENSURE_USER ERROR: $error');
      debugPrint('[Auth] STACKTRACE:\n$st');
      rethrow;
    }
  }
}


