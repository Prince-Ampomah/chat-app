/*import 'package:chatapp/services/db.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PhoneToken{
  String uid;
  PhoneToken({this.uid});

  FirebaseMessaging firebasemessaging = FirebaseMessaging();

  getPhoneToken(){
  firebasemessaging.getToken().then((token) {
    print('TOKEN: $token');
    return DatabaseServices(uid: uid).uploadPhoneToken(token);
  });
  
  }


}*/


