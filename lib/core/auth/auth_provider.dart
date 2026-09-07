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
      // Windows and Web use Firebase OAuth provider (googleSignIn not supported on Windows)
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
        debugPrint('[Auth] SIGNIN: Using Firebase OAuth provider flow (kIsWeb=$kIsWeb, platform=${defaultTargetPlatform})');
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        
        debugPrint('[Auth] SIGNIN: Calling signInWithProvider');
        await _auth.signInWithProvider(provider);
        debugPrint('[Auth] SIGNIN: signInWithProvider completed successfully');
        return;
      }

      // Android, iOS, macOS use native GoogleSignIn
      debugPrint('[Auth] SIGNIN: Using native GoogleSignIn flow ($defaultTargetPlatform)');
      debugPrint('[Auth] SIGNIN: Starting GoogleSignIn().signIn()');
      final googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      
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
        isLoading: false,
        errorMessage: () => 'User not found',
      );
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .update({'disclaimerAccepted': true});
    } catch (error) {
      debugPrint('[Auth] ERROR: Failed to accept disclaimer: $error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to accept disclaimer',
      );
    }
  }

  Future<void> signOut() async {
    debugPrint('[Auth] SIGNOUT: Starting sign-out');
    try {
      await _auth.signOut();
      if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows) {
        await GoogleSignIn().signOut();
      }
    } catch (error, st) {
      debugPrint('[Auth] ERROR: Failed to sign out: $error');
      debugPrint('[Auth] STACKTRACE:\n$st');
    }
  }

  void _handleFirebaseUser(User? firebaseUser) async {
    debugPrint('[Auth] HANDLE: Processing Firebase user. Email: ${firebaseUser?.email}');

    if (firebaseUser == null) {
      debugPrint('[Auth] HANDLE: User is null, setting to unauthenticated');
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userModel = UserModel.fromMap(userData, firebaseUser.uid);
        debugPrint('[Auth] HANDLE: User document found. Email: ${userModel.email}');

        state = AuthState(
          userModel: userModel,
          isAuthenticated: true,
          isLoading: false,
        );

        // If new user, set to false. If old user and hasn't accepted, show disclaimer
        if (userModel.disclaimerAccepted) {
          debugPrint('[Auth] HANDLE: Disclaimer already accepted');
        } else {
          debugPrint('[Auth] HANDLE: Disclaimer not accepted yet');
        }
      } else {
        // New user document
        debugPrint('[Auth] HANDLE: User document not found. Creating new user.');
        final now = DateTime.now();
        final trialStart = now;
        final trialEnd = now.add(Duration(days: 7));
        
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? 'unknown',
          createdAt: now,
          paymentStatus: 'unpaid',
          hasLifetimeAccess: false,
          trialStartDate: trialStart,
          trialExpiresAt: trialEnd,
          disclaimerAccepted: false,
          premiumActive: false,
        );

        // Create new user document
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());

        debugPrint('[Auth] HANDLE: Created new user document for ${firebaseUser.email}');

        state = AuthState(
          userModel: newUser,
          isAuthenticated: true,
          isLoading: false,
        );
      }
    } on FirebaseException catch (error, st) {
      debugPrint('[Auth] ERROR: Failed to fetch user: ${error.code} - ${error.message}');
      debugPrint('[Auth] STACKTRACE:\n$st');

      // Still authenticated, but user model unavailable
      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        errorMessage: 'Unable to load user profile: ${error.message}',
      );
    } catch (error, st) {
      debugPrint('[Auth] ERROR: Unexpected error: $error');
      debugPrint('[Auth] STACKTRACE:\n$st');

      state = AuthState(
        isAuthenticated: true,
        isLoading: false,
        errorMessage: 'An error occurred while loading your profile',
      );
    }
  }
}

