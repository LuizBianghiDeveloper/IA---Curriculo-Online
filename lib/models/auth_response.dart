class AuthResponse {
  final String? token;
  final String? username;
  final String? nome;
  final String? email;
  final String message;

  AuthResponse({
    this.token,
    this.username,
    this.nome,
    this.email,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String?,
      username: json['username'] as String?,
      nome: json['nome'] as String?,
      email: json['email'] as String?,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'username': username,
      'nome': nome,
      'email': email,
      'message': message,
    };
  }
  
  bool get isSuccess => token != null && token!.isNotEmpty;
}

