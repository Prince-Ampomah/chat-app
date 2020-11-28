import 'dart:async';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';


class InternetConnectivity extends ChangeNotifier{

  bool _isOnline;
  bool get getIsOnline => _isOnline;

  InternetConnectivity(){
    _isOnline = false;
    checkConnection();
  }

  StreamSubscription<DataConnectionStatus> listener;

  checkConnection() async{

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