class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? lastName;
  String? usertype;

  UserModel(
      {this.uid, this.email, this.firstName, this.lastName, this.usertype});

  //data fromserver
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      usertype: map['userType'],
    );
  }

  //send to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'userType': usertype,
    };
  }
}
