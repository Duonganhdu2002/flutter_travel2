import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt/crypt.dart';

class Auth {
  final String uid;
  final String? avatar;
  final List<dynamic>? bookMarkList;
  final String email;
  final String fullName;
  final List<dynamic>? inviteList;
  final List<dynamic>? listFriend;
  final String? location;
  final String password;
  final String? phone;
  final List<dynamic>? planList;
  final List<dynamic>? waitingList;

  Auth({
    required this.uid,
    this.avatar,
    this.bookMarkList,
    required this.email,
    this.fullName = '',
    this.inviteList,
    this.listFriend,
    this.location,
    required String password,
    this.phone,
    this.planList,
    this.waitingList,
  }) : password = Crypt.sha256(password).toString();

  factory Auth.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Auth(
      uid: snapshot.id,
      avatar: data['avatar'] as String?,
      bookMarkList: (data['book_mark_list'] as List<dynamic>?) ?? [],
      email: data['email'],
      fullName: data['fullname'] ?? '',
      inviteList: (data['invite_list'] as List<dynamic>?) ?? [],
      listFriend: (data['list_friend'] as List<dynamic>?) ?? [],
      location: data['location'] as String?,
      password: data['password'],
      phone: data['phone'] as String?,
      planList: (data['plan_list'] as List<dynamic>?) ?? [],
      waitingList: (data['waiting_list'] as List<dynamic>?) ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avatar': avatar,
      'book_mark_list': bookMarkList ?? [],
      'email': email,
      'fullname': fullName,
      'invite_list': inviteList ?? [],
      'list_friend': listFriend ?? [],
      'location': location,
      'password': password,
      'phone': phone,
      'plan_list': planList ?? [],
      'waiting_list': waitingList ?? [],
    };
  }
}
