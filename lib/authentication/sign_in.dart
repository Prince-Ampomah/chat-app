import 'package:chatapp/services/auth.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  bool isLoading = false;
  AuthServices authServices = AuthServices();

  signIn()async{
    try{
      setState(()=>isLoading = true);
      await authServices.signIn();
    }catch(e){
//      setState(()=>isLoading = false);
      print(e.toString());
      Fluttertoast.showToast(msg: '${e.toString()}');
    }
    authServices.signIn();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isLoading? circularProgress() : Container(),
              SizedBox(height: 20),
              GoogleSignInButton(
                onPressed: signIn,
                text: 'Sign In with Google',
                textStyle: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
                darkMode: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
