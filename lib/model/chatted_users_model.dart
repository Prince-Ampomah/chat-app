import 'package:cloud_firestore/cloud_firestore.dart';


class ChattedUsersModel{

   String receiverId;
   String receiverName;
   String receiverPhoto;
   String chatId;
   String message;
   String timestamp;


   ChattedUsersModel({this.receiverId, this.receiverName, this.receiverPhoto,
     this.chatId, this.message, this.timestamp});

   factory ChattedUsersModel.fromDocument(DocumentSnapshot doc){
     return ChattedUsersModel(
          receiverId: doc['receiverId'],
         receiverName: doc['receiverName'],
         receiverPhoto: doc['receiverPhoto'],
         chatId: doc['chatId'],
         message: doc['recentMessage'],
         timestamp: doc['timestamp']
     );
   }


}

class MessagesModel{

  String message;
  String timestamp;

  MessagesModel({this.message, this.timestamp});

  factory MessagesModel.fromDocument(DocumentSnapshot doc){
    return MessagesModel(
        message: doc['msgContent'],
        timestamp: doc['timestamp']
    );
  }

}

