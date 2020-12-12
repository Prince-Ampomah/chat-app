import 'dart:async';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


class InternetConnectivity extends ChangeNotifier{

  SharedPreferences preferences;
  String currentUserId;
  bool _isOnline;
  bool get getIsOnline => _isOnline;

  InternetConnectivity(){
    _isOnline = false;
    checkConnection();
  }

  StreamSubscription<DataConnectionStatus> listener;

  checkConnection() async{
    preferences = await SharedPreferences.getInstance();
    currentUserId = preferences.getString('id');
    print('inter: $currentUserId');

    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch(status){
        case DataConnectionStatus.connected:
          Fluttertoast.showToast(msg: 'Connected');
          _isOnline = true;
          notifyListeners();
          break;
        case DataConnectionStatus.disconnected:
          Fluttertoast.showToast(msg: 'Disconnected');
          _isOnline = false;
          notifyListeners();
          break;

      }
    });

    // close listener after 30 seconds, so the program doesn't run forever
    await Future.delayed(Duration(seconds: 15));
    await listener.cancel();
    return await DataConnectionChecker().connectionStatus;
  }

}