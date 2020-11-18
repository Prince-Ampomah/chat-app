import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  String uid;
  DatabaseServices({this.uid});


//Users Info DB
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  uploadUserInfo({userDetails}) async {
    return await usersCollection.doc(uid).set(userDetails).catchError((e) {
      print(' $e :Error Uploading User Details');
    });
  }


//Phone Token DB
  CollectionReference phoneTokenCollection =
      FirebaseFirestore.instance.collection('phone_token');

  uploadPhoneToken(String token) async {
    return await phoneTokenCollection.doc(uid).set({'token': token})
    .catchError((error)=>print('uploading phone token error: $error'));
  }
}
