import 'dart:convert';

LoginResponseModel loginResponseJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

class LoginResponseModel {
  String? id;
  String? fullname;
  String? username;
  String? email;
  String? location;
  String? phone;
  String? avatar;
  List<String>? roles;

  LoginResponseModel({
    this.id,
    this.username,
    this.fullname,
    this.email,
    this.location,
    this.avatar,
    this.roles,
    this.phone,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      id: json['id'],
      fullname: json['fullname'] ?? "",
      username: json['username'],
      email: json['email'],
      phone: json['phone'] ?? "",
      location: json["location"] ?? "",
      avatar: json["avatar"] ?? "",
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'fullname': fullname,
      'username': username,
      'email': email,
      'phone': phone,
      'location': location,
      'avatar': avatar,
      'roles': roles,
    };
    return data;
  }
}
