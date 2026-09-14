import 'user_model.dart';

class TokenModel {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  TokenModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}