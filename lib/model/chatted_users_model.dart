import 'package:cloud_firestore/cloud_firestore.dart';

class ChattedUserModel{

    String username;
    String photo;
    String message;
    String timestamp;

    ChattedUserModel({this.username, this.photo, this.message, this.timestamp});

    factory ChattedUserModel.fromDocument(DocumentSnapshot doc){
      return ChattedUserModel(
        username: doc['username'],
        photo: doc['photoUrl'],
        message: doc['msgContent'],
        timestamp: doc['timestamp']
      );
    }
    

    
}