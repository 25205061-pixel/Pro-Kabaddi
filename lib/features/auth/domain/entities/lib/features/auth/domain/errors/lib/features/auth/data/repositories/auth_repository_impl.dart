import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raid_masters_league/core/constants/app_constants.dart';

import '../../domain/entities/app_user_entity.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._googleSignIn, this._firestore);

  AppUserEntity _mapUser(fb.User user, AuthProviderType provider, {bool isNewUser = false}) {
    return AppUserEntity(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      phone: user.phoneNumber,
      photoUrl: user.photoURL,
      provider: provider,
      isNewUser: isNewUser,
    );
  }

  /// Creates the `users/{uid}` Firestore doc on first sign-in only.
  Future<void> _ensureUserDoc(fb.User user, {String? displayNameOverride}) async {
    final ref = _firestore.collection(AppConstants.collectionUsers).doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'displayName': displayNameOverride ?? user.displayName ?? '',
        'email': user.email,
        'phone': user.phoneNumber,
        'photoUrl': user.photoURL,
        'favoriteTeamId': null,
        'favoritePlayerIds': <String>[],
        'role': 'fan',
        'notificationSettings': {
          'liveMatch': true,
          'teamAlerts': true,
          'injuryUpdates': true,
          'breakingNews': true,
        },
        'watchHistory': <Map<String, dynamic>>[],
        'walletBalance': 0,
        'premiumMember': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Stream<AppUserEntity?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapUser(user, AuthProviderType.email); // provider refined per-flow
    });
  }

  @override
  AppUserEntity? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user, AuthProviderType.email);
  }

  @override
  Future<AppUserEntity> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthFailure.fromCode('google-sign-in-cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user!;
      await _ensureUserDoc(user);
      return _mapUser(user, AuthProviderType.google, isNewUser: result.additionalUserInfo?.isNewUser ?? false);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }

  @override
  Future<AppUserEntity> signInWithEmail({required String email, required String password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _mapUser(result.user!, AuthProviderType.email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }

  @override
  Future<AppUserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await result.user!.updateDisplayName(displayName);
      await _ensureUserDoc(result.user!, displayNameOverride: displayName);
      return _mapUser(result.user!, AuthProviderType.email, isNewUser: true);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }

  @override
  Future<String> startPhoneVerification(String phoneNumber) async {
    final completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {}, // auto-retrieval handled by SDK on Android
      verificationFailed: (e) => completer.completeError(AuthFailure.fromCode(e.code)),
      codeSent: (verificationId, _) => completer.complete(verificationId),
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );
    return completer.future;
  }

  @override
  Future<AppUserEntity> verifyOtp({required String verificationId, required String smsCode}) async {
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user!;
      await _ensureUserDoc(user);
      return _mapUser(user, AuthProviderType.phone, isNewUser: result.additionalUserInfo?.isNewUser ?? false);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }
}

// --- Riverpod wiring -------------------------------------------------------

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
    FirebaseFirestore.instance,
  );
});

final authStateProvider = StreamProvider<AppUserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
