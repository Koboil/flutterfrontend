class User {
  int userId;
  String firstName;
  String lastName;
  String email;
  String password; // Consider not storing passwords
  String role;
  int? tokensBalance; // Optional for roles that may not have this
  int? pointsEarned; // Optional for roles that may not have this

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    this.tokensBalance,
    this.pointsEarned,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      tokensBalance: json['tokens_balance'],
      pointsEarned: json['points_earned'],
    );
  }
}
