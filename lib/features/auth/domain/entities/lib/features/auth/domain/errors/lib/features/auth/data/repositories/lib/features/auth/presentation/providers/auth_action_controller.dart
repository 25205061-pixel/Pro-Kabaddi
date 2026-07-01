import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/errors/auth_failure.dart';

/// Generic async-action state used by every auth form (login, register,
/// forgot password, OTP) so screens can show a loading spinner + inline
/// error text without duplicating boilerplate.
class AuthActionState {
  final bool isLoading;
  final String? errorMessage;

  const AuthActionState({this.isLoading = false, this.errorMessage});

  AuthActionState copyWith({bool? isLoading, String? errorMessage}) => AuthActionState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

class AuthActionController extends StateNotifier<AuthActionState> {
  final Ref ref;
  AuthActionController(this.ref) : super(const AuthActionState());

  Future<AppUserEntity?> signInWithGoogle() => _run(() {
        return ref.read(authRepositoryProvider).signInWithGoogle();
      });

  Future<AppUserEntity?> signInWithEmail(String email, String password) => _run(() {
        return ref.read(authRepositoryProvider).signInWithEmail(email: email, password: password);
      });

  Future<AppUserEntity?> register(String name, String email, String password) => _run(() {
        return ref
            .read(authRepositoryProvider)
            .registerWithEmail(email: email, password: password, displayName: name);
      });

  Future<String?> startPhoneVerification(String phone) => _run(() {
        return ref.read(authRepositoryProvider).startPhoneVerification(phone);
      });

  Future<AppUserEntity?> verifyOtp(String verificationId, String smsCode) => _run(() {
        return ref
            .read(authRepositoryProvider)
            .verifyOtp(verificationId: verificationId, smsCode: smsCode);
      });

  Future<bool> sendPasswordReset(String email) async {
    final result = await _run(() async {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      return true;
    });
    return result ?? false;
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await action();
      state = state.copyWith(isLoading: false);
      return result;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Something went wrong. Please try again.');
      return null;
    }
  }
}

final authActionControllerProvider =
    StateNotifierProvider.autoDispose<AuthActionController, AuthActionState>(
  (ref) => AuthActionController(ref),
);
