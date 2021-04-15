import 'package:chatapp/model/user_model.dart';
import 'package:chatapp/screens/chat_page.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:chatapp/style/style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  SharedPreferences preferences;
  String currentUserId;
  String username;
  ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    readFromLocal();
    super.initState();
  }

  readFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    currentUserId = preferences.getString('id');
    username = preferences.getString('username');
    Fluttertoast.showToast(
        msg: 'Logged in as: $username');

    if(this.mounted){
      setState(() {});
    }
  }

  Widget allUsers() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('username', descending: false)
          .where('username', isNotEqualTo: username)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return noUsersData(
              info: 'No Users\n All users will be listed here, once they log in');
        if (snapshot.hasError) return Text('${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting)
          return loadingData();

        return Scrollbar(
          thickness: 3.0,
          radius: Radius.circular(10.0),
          child: ListView.separated(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    snapshot.data.documents[index];
                return createUsersList(documentSnapshot);
              },
              separatorBuilder: (context, index) {
                return Divider();
              }),
        );
      },
    );
  }

  Widget createUsersList(DocumentSnapshot documentSnapshot) {
    //User from User Model
    User eachUser = User(
        id: documentSnapshot.id,
        username: documentSnapshot['username'],
        photoUrl: documentSnapshot['photoUrl'],
        createdAt: documentSnapshot['createdAt']);
    return FlatButton(
      onPressed: () async{
        if (currentUserId != documentSnapshot.data()['id']) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
            builder: (context)=>ChattingPage(
              receiverId: eachUser.id,
              receiverAvatar: eachUser.photoUrl,
              receiverName: eachUser.username,
            ),
          )
          );

        } else {
          Fluttertoast.showToast(
              msg: 'You\'re logged in as ${documentSnapshot['username']}');
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
        child: Row(
          children: <Widget>[
            //Image
            Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5)),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Styles.appBarColor,
                  backgroundImage: CachedNetworkImageProvider(
                      documentSnapshot.data()['photoUrl'].toString()),
                )),

            SizedBox(
              width: 25.0,
            ),

            //Username
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
                    documentSnapshot.data()['aboutMe'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        elevation: 0.0,
        title: Text('Chat App'),
      ),
      body: Container(child: allUsers()),
    );
  }
}
