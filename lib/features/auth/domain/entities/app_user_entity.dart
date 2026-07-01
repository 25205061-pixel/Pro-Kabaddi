import 'package:equatable/equatable.dart';

enum AuthProviderType { google, email, phone }

class AppUserEntity extends Equatable {
  final String uid;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final AuthProviderType provider;
  final bool isNewUser;
  final String? favoriteTeamId;

  const AppUserEntity({
    required this.uid,
    required this.provider,
    this.displayName,
    this.email,
    this.phone,
    this.photoUrl,
    this.isNewUser = false,
    this.favoriteTeamId,
  });

  @override
  List<Object?> get props =>
      [uid, displayName, email, phone, photoUrl, provider, isNewUser, favoriteTeamId];
}
