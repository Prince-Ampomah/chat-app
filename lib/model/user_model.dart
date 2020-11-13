//import 'package:cloud_firestore/cloud_firestore.dart';
class User{
  String id;
  String username;
  String photoUrl;
  String createdAt;

  User({this.id, this.username, this.photoUrl, this.createdAt});

//  factory User.fromDocument(DocumentSnapshot doc){
//    return User(
//      id: doc.id,
//      username: doc['username'],
//      photoUrl: doc['photoUrl'],
//      createdAt: doc['createdAt']
//    );
//  }

}

