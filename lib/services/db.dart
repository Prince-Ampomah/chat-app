import 'package:cloud_firestore/cloud_firestore.dart';
class DatabaseServices{
  String uid;
  DatabaseServices({this.uid});

  CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');

  uploadUserInfo({userDetails}) async{
    return await usersCollection.doc(uid).set(userDetails)
        .catchError((e){
          print(' $e :Error Uploading User Details');
    });
  }
}