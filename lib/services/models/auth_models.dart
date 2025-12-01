class SignUpRequest {
  final String userName;
  final String email;
  final String password;

  SignUpRequest({
    required this.userName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'email': email,
        'password': password,
      };
}

class SignInRequest {
  final String email;
  final String password;

  SignInRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class User {
  final String id;
  final String email;
  final String userName;
  final String? role;

  User({
    required this.id,
    required this.email,
    required this.userName,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'userName': userName,
        'role': role,
      };
}

class SignInResponse {
  final String token;
  final User user;

  SignInResponse({
    required this.token,
    required this.user,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}





