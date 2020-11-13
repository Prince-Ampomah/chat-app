import 'package:chatapp/screens/settings_page.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/style/style.dart';
import 'package:chatapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget circularProgress() {
  return CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(Styles.appBarColor),
  );
}

Widget popMenu(BuildContext context) {
  return PopupMenuButton<String>(
    itemBuilder: (context) {
      return Utils.menuItems.map((items) {
        return PopupMenuItem<String>(value: items, child: Text(items));
      }).toList();
    },
    onSelected: (value) => onChangeRoute(value, context),
  );
}

onChangeRoute(String item, BuildContext context) async {
  switch (item) {
    case Utils.logout:
      await AuthServices().signOut();
      break;

    case Utils.settings:
     Navigator.push(
          context, MaterialPageRoute(builder: (context) => Settings()));
      break;

    default:
      Fluttertoast.showToast(msg: 'No Item Selected');
  }
}
