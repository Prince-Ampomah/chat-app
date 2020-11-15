import 'package:chatapp/screens/settings_page.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/style/style.dart';
import 'package:chatapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

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

Widget loadingData() {
  return Container(
    child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          int offset = 0;
          offset += 7;
          int time = 800 + offset;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.white,
              period: Duration(milliseconds: time),
              child: Row(
                children: <Widget>[
                  //Image
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),

                  SizedBox(
                    width: 15.0,
                  ),

                  //Username
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 18,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          height: 18,
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
  );
}

Widget noDataPlaceholder() {
  return Container(
    margin: EdgeInsets.all(15.0),
    child: ListView.builder(
        shrinkWrap: true,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: Row(
              children: <Widget>[
                //Image
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),

                SizedBox(
                  width: 10.0,
                ),

                //Username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 15,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 15,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
  );
}

Widget noUsersData() {
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      noDataPlaceholder(),
      SizedBox(height: 10.0),
      Text('No Users'),
      SizedBox(height: 5.0),
      Text('All users will be listed here, once they log in')
    ],
  ));
}

Widget chatImagePlaceholder() {
  return Shimmer.fromColors(
     baseColor: Colors.grey[300],
     highlightColor: Colors.white,
      child: Container(
      width: 200.0,
      height: 200.0,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  );
}
