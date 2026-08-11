import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

/// The pair returned by `POST /auth/login` and `POST /auth/refresh`
/// (PRD §5.1.1, §5.1.2).
///
/// This is the only shape tokens travel in *between* the data layer and
/// [TokenStorage]. They are never held in a provider's state, never logged,
/// and never leave secure storage once persisted (PRD §6.1).
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
