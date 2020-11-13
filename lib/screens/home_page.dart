import 'package:chatapp/screens/all_users_page.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
//  final String receiverId;
//  final String receiverAvatar;
//  final String receiverName;

  // HomePage({this.receiverId, this.receiverAvatar, this.receiverName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences preferences;
  String id;
  String receiverId = '';
  String receiverName = '';
  String receiverAvatar = '';

  @override
  void initState() {
    readFromLocal();
    super.initState();
  }

  void readFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    receiverName = preferences.getString('recieverName');
    receiverId = preferences.getString('recieverId');
    receiverAvatar = preferences.getString('recieverAvatar');
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AllUsers()));
        },
        child: Icon(Icons.message),
      ),
      appBar: AppBar(
        title: Text('Chat App'),
        actions: [popMenu(context)],
        elevation: 0.0,
      ),
      body: Container(

      ),
    );
  }
}

// class ChatListTile extends StatelessWidget {
//  final String receiverId;
//  final String receiverName;
//  final String recieverAvatar;
//  ChatListTile({this.receiverId, this.receiverName, this.recieverAvatar});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: <Widget>[
//         Container(
//           height: 50,
//           width: 50,
//           clipBehavior: Clip.hardEdge,
//           decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.red, width: 1.5)),
//         ),

//         SizedBox(
//           width: 25.0,
//         ),

//         //Username and AboutMe
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Container(
//                   child: Text(
//                 receiverName ?? '',
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               )),
//               SizedBox(
//                 height: 10.0,
//               ),
//               Container(
//                   child: Text(
//                 receiverId ?? '',
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               )),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
