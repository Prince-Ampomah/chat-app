import 'package:chatapp/authentication/auth_listener.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AuthServices authServices = AuthServices();
    return StreamProvider.value(
      value: authServices.streamUser,
      child: ChangeNotifierProvider<ThemeChanger>(
        create: (context)=> ThemeChanger(),
        child: Consumer<ThemeChanger>(
          builder: (context, ThemeChanger themeChanger, child){
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Chat App',
                theme: themeChanger.darkTheme? darkTheme : lightTheme,
                home: AuthListener()
            );
          },

        ),
      ),
    );
  }
}

