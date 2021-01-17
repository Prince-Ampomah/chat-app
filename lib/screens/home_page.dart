import 'package:chatapp/animation/routing_page_animation.dart';
import 'package:chatapp/constants/strings.dart';
import 'package:chatapp/model/chatted_users_model.dart';
import 'package:chatapp/screens/signed_in_users_page.dart';
import 'package:chatapp/screens/chat_page.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:chatapp/style/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences preferences;
  String id;
  String chatId;

  Stream<QuerySnapshot> streamAllChattedUsers;
  Stream<QuerySnapshot> streamMessages;

  @override
  void initState() {
    readFromLocal();
    streamChattedUsers();
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
    setState(() {});
  }

  streamChattedUsers() async {
    preferences = await SharedPreferences.getInstance();
    chatId = preferences.getString('chatId');

    Stream<QuerySnapshot> allChattedUsers = FirebaseFirestore.instance
        .collection('chattedUsers')
        .orderBy('timestamp', descending: true)
        .snapshots();
    setState(() {
      streamAllChattedUsers = allChattedUsers;
    });
  }

  streamMessagesList() async {
    preferences = await SharedPreferences.getInstance();
    chatId = preferences.getString('chatId');
    setState(() {});

    Stream<QuerySnapshot> listAllMessages = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection(chatId)
        .orderBy('timestamp', descending: true)
        .snapshots();
    setState(() {
      streamMessages = listAllMessages;
    });
  }

  showChattedUsers() {
    return StreamBuilder(
      stream: streamAllChattedUsers,
      builder: (context, chattedUsersSnapshot) {
        if (!chattedUsersSnapshot.hasData) return Center(child: loadingData());
        if (chattedUsersSnapshot.hasError)
          return Center(child: Text('Error: ${chattedUsersSnapshot.error}'));

        if (chattedUsersSnapshot.connectionState == ConnectionState.waiting)
          return Center(child: Text('Connecting.....'));

        return ListView.separated(
          itemCount: chattedUsersSnapshot.data.documents.length,
          itemBuilder: (context, index) {
            final DocumentSnapshot documentSnapshot =
                chattedUsersSnapshot.data.documents[index];
            ChattedUsersModel chattedUsersModel =
                ChattedUsersModel.fromDocument(documentSnapshot);
            return ChattedUserResult(
              chattedUsersModel: chattedUsersModel,
            );
          },
          separatorBuilder: (context, index) => Divider(),
        );
      },
    );
  }

  showNoChatList() {
    return noUsersData(info: info);
  }

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
                ));
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
        body: streamAllChattedUsers != null
            ? showChattedUsers()
            : showNoChatList());
  }
}

class ChattedUserResult extends StatelessWidget {
  final ChattedUsersModel chattedUsersModel;
  final MessagesModel messagesModel;
  ChattedUserResult({this.chattedUsersModel, this.messagesModel});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChattingPage(
                      receiverId: chattedUsersModel.receiverId,
                      receiverName: chattedUsersModel.receiverName,
                      receiverAvatar: chattedUsersModel.receiverPhoto,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            //Image
            CircleAvatar(
              radius: 25,
              backgroundColor: Styles.appBarColor,
              backgroundImage: CachedNetworkImageProvider(
                  chattedUsersModel.receiverPhoto.toString()),
            ),

            SizedBox(
              width: 20.0,
            ),

            //Username and Messages
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(chattedUsersModel.receiverName ?? 'Name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(chattedUsersModel.message ?? 'Recent Messages',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0,
                      )),
                ],
              ),
            ),

            //time and n0 of messages
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                      DateFormat.jm().format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(chattedUsersModel.timestamp))) ??
                          'time',
                      style: TextStyle(fontSize: 11)),
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
                    child: Text('1',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 11.0)),
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

/*
msgSnapshot.data.documents.forEach((doc){
MessagesModel messagesModel = MessagesModel.fromDocument(doc);
UserResult userResult = UserResult(
messagesModel: messagesModel);
listUserResult.add(userResult);
});

chattedUsersSnapshot.data.documents.forEach((doc){
ChattedUsersModel chattedUsersModel = ChattedUsersModel.fromDocument(doc);
UserResult userResult = UserResult(
chattedUsersModel: chattedUsersModel);
listUserResult.add(userResult);
});*/
