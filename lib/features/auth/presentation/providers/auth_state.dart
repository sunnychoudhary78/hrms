import '../../data/models/user_model.dart';
import '../../../profile/data/models/user_details_model.dart';

class AuthState {
  final bool isLoading;
  final User? authUser;
  final Userdetails? profile;
  final String profileUrl;
  final List<String> permissions;

  const AuthState({
    this.isLoading = false,
    this.authUser,
    this.profile,
    this.profileUrl = '',
    this.permissions = const [],
  });

  AuthState copyWith({
    bool? isLoading,
    User? authUser,
    Userdetails? profile,
    String? profileUrl,
    List<String>? permissions,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      authUser: authUser ?? this.authUser,
      profile: profile ?? this.profile,
      profileUrl: profileUrl ?? this.profileUrl,
      permissions: permissions ?? this.permissions,
    );
  }
}
