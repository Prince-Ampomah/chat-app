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

  @override
  void initState() {
    readFromLocal();
    super.initState();
  }

  readFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    currentUserId = preferences.getString('id');
    setState(() {});
  }

  Stream streamUsers = FirebaseFirestore.instance
      .collection('users')
      .orderBy('username', descending: false)
      .snapshots();

  Widget allUsers() {
    return StreamBuilder(
      stream: streamUsers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) 
        return noUsersData();
        if (snapshot.hasError) return Text('${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting)
          return loadingData();
        return new ListView.separated(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot documentSnapshot =
                  snapshot.data.documents[index];
              return createUsersList(index, documentSnapshot);
            },
            separatorBuilder: (context, index) {
              return Divider();
            });
      },
    );
  }

  Widget createUsersList(int index, DocumentSnapshot documentSnapshot) {

    //User from User Model
    User eachUser = User(
        id: documentSnapshot.id,
        username: documentSnapshot['username'],
        photoUrl: documentSnapshot['photoUrl'],
        createdAt: documentSnapshot['createdAt']);

    return FlatButton(
      onPressed: () {
        if (currentUserId != documentSnapshot.data()['id']) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return ChatingPage(
              receiverId: eachUser.id,
              receiverAvatar: eachUser.photoUrl,
              receiverName: eachUser.username,
            );
          }));
        } else {
          Fluttertoast.showToast(msg: 'Not Allowed');
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
