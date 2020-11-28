import 'package:chatapp/animation/routing_page_animation.dart';
import 'package:chatapp/model/chatted_users_model.dart';
import 'package:chatapp/screens/all_users_page.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:chatapp/style/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
  Stream<QuerySnapshot> streamResult;

  @override
  void initState() {
    readFromLocal();
    // streamChattedUsers();
    loadChattedUsers();
//    InternetConnectivity().checkConnection();
    super.initState();
  }

//  @override
//  void dispose() {
//    InternetConnectivity().listener.cancel();
//    super.dispose();
//  }


  void readFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    // chatId = preferences.getString('chatId');
    // print('SAVED CHAT ID: $chatId');
    setState(() {});
  }

  loadChattedUsers() async {
    preferences = await SharedPreferences.getInstance();
    chatId = preferences.getString('chatId');
    setState(() {});

    Future<QuerySnapshot> allChattedUsers = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection(chatId)
        .orderBy('timestamp', descending: true)
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
        if (!snapshot.hasData) return Center(child: loadingData());

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
    return noUsersData(users: 'No Chatted List',info: info);
  }

/*  streamChattedUsers() {
    Stream<QuerySnapshot> allUsers = FirebaseFirestore.instance
        .collection('messages')
        .doc('jNiCHZ557SVmW3yRfESRMbOEFWw2_4NJxrHXHNpXAeGUWIwyKUXP3we73')
        .collection('jNiCHZ557SVmW3yRfESRMbOEFWw2_4NJxrHXHNpXAeGUWIwyKUXP3we73')
        .snapshots();
    setState(() {
      streamResult = allUsers;
    });
  }

  showChattedUsers(){
    return StreamBuilder(
      stream: streamResult,
      builder: (context, snapshot){
        return ListView.separated(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              final DocumentSnapshot documentSnapshot =
                  snapshot.data.documents[index];
              return  FlatButton(
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
                                  documentSnapshot.data()['username'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            SizedBox(
                              height: 10.0,
                            ),
                            Container(
                                child: Text(
                                  documentSnapshot.data()['msgContent'],
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
            },
            separatorBuilder: (context, index)=>Divider(),
            );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Styles.appBarColor,
          onPressed: () {
            Navigator.push(
                context,
                AnimatePageRoute(
                    widget: AllUsers(),
                    alignment: Alignment.bottomRight,
                    duration: Duration(milliseconds: 500),
                )
            );
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
        body:
            futureBuilderResult != null ? showChattedList() : showNoChatList());
  }
}

class UserResult extends StatelessWidget {
  final ChattedUserModel chattedUserModel;

  UserResult({this.chattedUserModel});

  @override
  Widget build(BuildContext context) {
    SharedPreferences preferences;
    return FlatButton(
      onPressed: () async {
        preferences = await SharedPreferences.getInstance();

//        Navigator.push(context,
//            MaterialPageRoute(
//              builder: (context)=>ChattingPage(
//
//              ),
//            )
//        );
        Fluttertoast.showToast(msg: 'Goes to chatting page');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[

            //Image
            Container(
                height: 50,
                width: 50,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 1.5)),
                child: CachedNetworkImage(
                  height: 50,
                  width: 50,
                  imageUrl: chattedUserModel.photo,
                  placeholder: (context, url) => circularProgress(),
                  errorWidget: (context, url, dynamic)=> Icon(Icons.person)

                )),

            SizedBox(
              width: 20.0,
            ),

            //Username and Messages
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text(
                    chattedUserModel.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  )),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      child: Text(
                    chattedUserModel.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.0,
                    )
                  )),
                ],
              ),
            ),

            //time and n0 of messages
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(DateFormat.jm().format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(chattedUserModel.timestamp))),
                  style: TextStyle(
                    fontSize: 11
                  )),

                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Styles.appBarColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      '1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.0
                      )
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
