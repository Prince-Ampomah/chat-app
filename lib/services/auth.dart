import 'package:chatapp/model/firebase_user_model.dart';
import 'package:chatapp/notification/phone_token.dart';
import 'package:chatapp/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSign = GoogleSignIn();
  User currentUser;
  SharedPreferences preferences;

  FirebaseUserModel _firebaseUser(User user) {
    return user != null ? FirebaseUserModel(id: user.uid) : null;
  }

  Stream<FirebaseUserModel> get streamUser {
    return _firebaseAuth.authStateChanges().map(_firebaseUser);
  }

  Future<bool> signIn() async {
    try {
      //Authenticate Google Account
      GoogleSignInAccount googleSignInAccount = await _googleSign.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(authCredential);
      User user = userCredential.user;

      //Is user empty
      if (user != null) {
        final QuerySnapshot queryResult = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .get();
        final List<DocumentSnapshot> docSnapshot = queryResult.docs;

        //save new user info
        if (docSnapshot.length == 0) {
          Map<String, dynamic> userDetails = {
            'id': user.uid,
            'username': user.displayName,
            'photoUrl': user.photoURL,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'aboutMe': 'I\'m a developer',
            'chattingWith': null
          };

          DatabaseServices databaseServices = DatabaseServices(uid: user.uid);
          databaseServices.uploadUserInfo(userDetails: userDetails);

          
          //Store User Info on local storage
          currentUser = user;
          preferences = await SharedPreferences.getInstance();
          await preferences.setString('id', currentUser.uid);
          await preferences.setString('username', currentUser.displayName);
          await preferences.setString('photoUrl', currentUser.photoURL);
        } else {
          await preferences.setString('id', docSnapshot[0]['id']);
          await preferences.setString('username', docSnapshot[0]['username']);
          await preferences.setString('photoUrl', docSnapshot[0]['photoUrl']);
          await preferences.setString('aboutMe', docSnapshot[0]['aboutMe']);
          
        }
      }

      _firebaseUser(user);
    } catch (e) {
      print(e.toString());
    }

    return Future.value(true);
  }

  Future signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSign.disconnect();
      await _googleSign.signOut();
    } catch (e) {
      print('${e.toString()}: Error Signing Out');
    }
  }
}
