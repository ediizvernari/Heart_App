class AuthResponse {
  final String accessToken;
  final String tokenType;
  final String role;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      role: json['role'] as String,
    );
  }
}