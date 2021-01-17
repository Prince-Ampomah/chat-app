import 'package:chatapp/authentication/sign_in.dart';
import 'package:chatapp/model/firebase_user_model.dart';
import 'package:chatapp/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthListener extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUserModel>(context);

    if (user != null) {
      return HomePage();
    } else {
      return SignIn();
    }
  }
}
