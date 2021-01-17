import 'package:chatapp/services/auth.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  AuthServices authServices = AuthServices();

  signIn() async {
    try {
      setState(() => isLoading = true);
      await authServices.signIn();
    } catch (e) {
      print('ERROR: ${e.toString()}');
      if(this.mounted){
        setState(() {
          isLoading = false;
        });
      }
    }

    //check  internet connectivity
    bool result = await DataConnectionChecker().hasConnection;
    if (result == false) {
      if(this.mounted){
        setState(() {
          isLoading = false;
        });
      }

      Fluttertoast.showToast(msg: 'Check your connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isLoading ? circularProgress() : Container(),
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
