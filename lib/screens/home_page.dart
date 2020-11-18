import 'package:chatapp/animation/routing_page_animation.dart';
import 'package:chatapp/model/chatted_users_model.dart';
import 'package:chatapp/screens/all_users_page.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:chatapp/style/style.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences preferences;
  String id;
  String chatId;

  String info = 'All chat users will be listed here,\nonce you start chatting';

  Future<QuerySnapshot> futureBuilderResult;

  @override
  void initState() {
    readFromLocal();
    super.initState();
  }

  void readFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    // chatId = preferences.getString('chatId');
    // print('SAVED CHAT ID: $chatId');
    setState(() {});
  }

  loadChattedUsers() async {
    Future<QuerySnapshot> allChattedUsers = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId ?? 'empty')
        .collection(chatId ?? 'empty')
        .get()
        .whenComplete(() => print('COMPLETED'));
    setState(() {
      futureBuilderResult = allChattedUsers;
    });
  }

  showChattedList() {
    return FutureBuilder(
      future: futureBuilderResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: Text('has no data'));

        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: Text('Connecting.....'));

        print("SNAPSHOT DATA: ${snapshot.hasData}");

        List<UserResult> searchUserResult = [];

        // Fix Problem Here
        snapshot.data.documents.forEach((doc) {
          ChattedUserModel chattedUserModel =
              ChattedUserModel.fromDocument(doc);
          UserResult userResult = UserResult(
            chattedUserModel: chattedUserModel,
          );
          searchUserResult.add(userResult);
        });
        return ListView(children: searchUserResult);
      },
    );
  }

  showNoChatList() {
    return Center(child: Icon(Icons.group));
  }

  chattedList() {
    return ListView(children: [
      FlatButton(
        onPressed: () {
          Fluttertoast.showToast(msg: 'Goes to chatting page');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(
                height: 50,
                width: 50,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 1.5)),
              ),

              SizedBox(
                width: 25.0,
              ),

              //Username and AboutMe
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text(
                      "Username",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                        child: Text(
                      "Recent Messages",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Styles.appBarColor,
          onPressed: () {
            Navigator.push(
                context,
               AnimatePageRoute(widget: AllUsers(),
                   alignment: Alignment.bottomRight,
               duration: Duration(milliseconds: 500)));
          },
          child: Icon(
            Icons.message,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(
          backgroundColor: Styles.appBarColor,
          title: Text('Chat App'),
          actions: [popMenu(context)],
          elevation: 0.0,
        ),
        body: noUsersData(users: 'No Users', info: info));
  }
}

class UserResult extends StatelessWidget {
  final ChattedUserModel chattedUserModel;
  UserResult({this.chattedUserModel});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Fluttertoast.showToast(msg: 'Goes to chatting page');
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 1.5)),
            ),

            SizedBox(
              width: 25.0,
            ),

            //Username and AboutMe
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text(
                    'username',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      child: Text(
                    'messages',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
