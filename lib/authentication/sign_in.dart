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
      print('WHEN ACCOUNT IS NOT SELECTED ERROR: ${e.toString()}');
      Fluttertoast.showToast(msg: 'No Account Selected');
      setState(() {
        isLoading = false;
      });
    }

    bool result = await DataConnectionChecker().hasConnection;
    if (result == false) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'No Internet Connection');
    }
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
