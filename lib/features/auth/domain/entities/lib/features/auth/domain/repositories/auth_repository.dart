import '../entities/app_user_entity.dart';

abstract class AuthRepository {
  Stream<AppUserEntity?> authStateChanges();
  AppUserEntity? get currentUser;

  Future<AppUserEntity> signInWithGoogle();

  Future<AppUserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUserEntity> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Starts phone OTP flow. Returns a verificationId the UI holds onto
  /// and later passes to [verifyOtp] along with the code the user typed.
  Future<String> startPhoneVerification(String phoneNumber);

  Future<AppUserEntity> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
