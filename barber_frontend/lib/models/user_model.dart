class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePic;
  final String? location;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePic,
    this.location,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profilePic: json['profilePic'],
      location: json['location'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'profilePic': profilePic,
      'location': location,
      'token': token,
    };
  }
}
