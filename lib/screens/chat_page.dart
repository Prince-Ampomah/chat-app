import 'dart:io';
import 'package:chatapp/screens/chat_photo_view.dart';
import 'package:chatapp/screens/chat_profile_pic_view.dart';
import 'package:chatapp/screens/home_page.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:chatapp/style/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ChattingPage extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;

  ChattingPage({this.receiverId, this.receiverAvatar, this.receiverName});

  @override
  _ChattingPageState createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  SharedPreferences preferences;
  bool isDisplaySticker;
  bool isLoading;
  bool isOnline = true;
  bool hideSendButton;
  bool hideScrollDownwardButton;

  String chatId;
  String currentUserId;

  File imageFile;
  String imageUrl;

  TextEditingController messageController = TextEditingController();
  FocusNode keyboardFocusNode = FocusNode();
  ScrollController scrollController;

  // String timeStamp =  DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    chatId = '';
    isDisplaySticker = false;
    isLoading = false;
    hideScrollDownwardButton = true;
    hideSendButton = true;
    keyboardFocusNode.addListener(focusNodeListener);
    scrollController = ScrollController();
    // scrollController.addListener(scrollListener);
    readFromLocal();
    super.initState();
  }

  // scrollListener(){

  //   if(scrollController.offset >= scrollController.position.maxScrollExtent
  //    && !scrollController.position.outOfRange){
  //       setState(() {
  //         hideScrollDownwardButton = false;
  //         Fluttertoast.showToast(msg: 'Reach Bottom');
         
  //       });
  //   }
  // }

  readFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    currentUserId = preferences.getString('id');
    print('currentUserId: $currentUserId');

    if (currentUserId.hashCode <= widget.receiverId.hashCode) {
      chatId = '${currentUserId}_${widget.receiverId}';
    } else {
      chatId = '${widget.receiverId}_$currentUserId';

      print("ChatId: $chatId");
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({"chattingWith": widget.receiverId});

    setState(() {});
  }

  focusNodeListener() {
    if (keyboardFocusNode.hasFocus) {
      setState(() {
        isDisplaySticker = false; //hide stickers
        hideSendButton = false; //show send Button
      });
    }
//    else {
//      setState(() {
//        hideSendButton = true; //show send Button
//      });
//    }
  }

  getStickers() {
    keyboardFocusNode.unfocus(); //hide keyboard
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  getImage() async {
    PickedFile pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(msg: 'No Image Selected', gravity: ToastGravity.CENTER);
    }

    uploadImage();
  }

  uploadImage() {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('Chat Images')
        .child(fileName);

    firebase_storage.UploadTask uploadTask =
        storageReference.putFile(imageFile);
    firebase_storage.TaskSnapshot storageTaskSnapshot;

    uploadTask.whenComplete(() {
      print('Completed Uploading Task');
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'when complete error: $error');
      setState(() {
        isLoading = false;
      });
    }).then((value) {
      storageTaskSnapshot = value;
      storageTaskSnapshot.ref.getDownloadURL().then((newImageSelected) {
        imageUrl = newImageSelected;
        setState(() {
          onMessageSend(imageUrl, 1);
          isLoading = false;
          print(imageUrl);
        });
      }, onError: (error) {
        Fluttertoast.showToast(msg: 'Download Url Error: $error');
        setState(() {
          isLoading = false;
        });
      });
    }, onError: (error) {
      Fluttertoast.showToast(msg: 'Storage Task Snapshot Error: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  createStickers() {
    return Container(
      height: 180.0,
      decoration: BoxDecoration(
          border:
              Border.all(width: 1.0, color: Colors.white10.withOpacity(0.5))),
      child: Column(
        children: [
          //1st Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => onMessageSend('mimi1', 2),
                child: Image.asset('assets/gifs/mimi1.gif',
                    height: 50, width: 50, fit: BoxFit.cover),
              ),
              GestureDetector(
                onTap: () => onMessageSend('mimi2', 2),
                child: Image.asset('assets/gifs/mimi2.gif',
                    height: 50, width: 50, fit: BoxFit.cover),
              ),
              GestureDetector(
                onTap: () => onMessageSend('mimi3', 2),
                child: Image.asset('assets/gifs/mimi3.gif',
                    height: 50, width: 50, fit: BoxFit.cover),
              ),
            ],
          ),

          //2nd Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => onMessageSend('mimi4', 2),
                child: Image.asset('assets/gifs/mimi4.gif',
                    height: 50, width: 50, fit: BoxFit.cover),
              ),
              GestureDetector(
                onTap: () => onMessageSend('mimi5', 2),
                child: Image.asset('assets/gifs/mimi5.gif',
                    height: 50, width: 50, fit: BoxFit.cover),
              ),
              GestureDetector(
                onTap: () => onMessageSend('mimi6', 2),
                child: Image.asset('assets/gifs/mimi6.gif',
                    height: 50, width: 50, fit: BoxFit.cover),
              ),
            ],
          ),

          //3rd Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => onMessageSend('mimi7', 2),
                child: Image.asset('assets/gifs/mimi7.gif',
                    height: 50, width: 50, fit: BoxFit.cover),
              ),
              GestureDetector(
                onTap: () => onMessageSend('mimi8', 2),
                child: Image.asset('assets/gifs/mimi8.gif',
                    height: 50, width: 50, fit: BoxFit.cover),
              ),
              GestureDetector(
                onTap: () => onMessageSend('mimi9', 2),
                child: Image.asset(
                  'assets/gifs/mimi9.gif',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  createMessageListItem(int index, DocumentSnapshot documentSnapshot) {
    var getData = documentSnapshot.data();
    final bool isSendByMe = getData['sendBy'] == currentUserId; //check sender

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 10),
        child: getData['type'] == 0
            ?

            //Text Container
            Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: isSendByMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  //Send Image
                  isSendByMe
                      ? Container()
                      : Container(
                          margin: EdgeInsets.all(5.0),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: CachedNetworkImage(
                              width: 30.0,
                              height: 30.0,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: circularProgress(),
                                  ),
                              imageUrl: widget.receiverAvatar),
                        ),

                  //Text And Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isSendByMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            right: isSendByMe ? 10.0 : 70.0,
                            left: isSendByMe ? 70.0 : 10.0,
                            bottom: 4.0,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 12.0),
                          decoration: BoxDecoration(
                              color: isSendByMe
                                  ? Color.fromRGBO(192, 214, 255, 5.0)
                                  : Color.fromRGBO(222, 214, 243, 5.0),
                              borderRadius: isSendByMe
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15))
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    )),
                          child: Column(
                            children: [
                              Text(
                                getData['msgContent'],
                                style: TextStyle(color: Styles.appBarColor),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: isSendByMe ? 0.0 : 10.0,
                            right: isSendByMe ? 10.0 : 0.0,
                          ),
                          padding: EdgeInsets.only(
                            left: isSendByMe ? 0.0 : 2.0,
                            right: isSendByMe ? 2.0 : 0.0,
                          ),
                          alignment: isSendByMe
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft,
                          child: Text(
                              DateFormat.E().add_MMM().add_jm().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(getData['timestamp']))),
                              style: TextStyle(fontSize: 9.0)),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : getData['type'] == 1
                ?

                //Image Container
                Container(
                    alignment: isSendByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    margin: EdgeInsets.all(5.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPhotoView(
                                            photo: getData['msgContent'],
                                          )));
                            },
                            child: Material(
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.circular(20.0),
                              child: CachedNetworkImage(
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    chatImagePlaceholder(),
                                imageUrl: getData['msgContent'],
                                errorWidget: (context, url, dynamic) {
                                  return Material(
                                    clipBehavior: Clip.hardEdge,
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Container(
                                        child: Center(
                                            child: Icon(Icons.cloud_upload))),
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            child: Text(
                              DateFormat.E().add_MMM().add_jm().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(getData['timestamp']))),
                              style: TextStyle(fontSize: 9.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                :

                //Emoji container
                Container(
                    width: 100.0,
                    height: 100.0,
                    alignment: isSendByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    margin: EdgeInsets.all(5.0),
                    child: Image.asset(
                      'assets/gifs/${getData['msgContent']}.gif',
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ));
  }

  Widget messageStream() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId)
            .collection(chatId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();

          if (snapshot.hasError) return Center(child: Text('$snapshot.error'));

          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: circularProgress());

          return Scrollbar(
            controller: scrollController,
            thickness: 3.0,
            radius: Radius.circular(10.0),
            child: ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                controller: scrollController,
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      snapshot.data.documents[index];
                  return InkWell(
                    onTap: () {
                      Fluttertoast.showToast(msg: 'Pressed');
                    },
                    onLongPress: () {
                      Fluttertoast.showToast(msg: 'Long Pressed');
                    },
                    child: createMessageListItem(index, documentSnapshot),
                  );
                }),
          );
        });
  }

  createMessagesList() {
    return Flexible(
        child:
            chatId == '' ? Center(child: circularProgress()) : messageStream());
  }

  createInputField() {
    return Container(
      child: Row(
        children: [
          SizedBox(
            width: 5.0,
          ),

          //Emoji or Gif Button
          GestureDetector(onTap: getStickers, child: Icon(Icons.tag_faces)),
          SizedBox(
            width: 10,
          ),

          //Image Button
          GestureDetector(onTap: getImage, child: Icon(Icons.image)),

          //Text Field
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: Styles.appBarColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                textAlign: TextAlign.justify,
                maxLines: 2,
                controller: messageController,
                focusNode: keyboardFocusNode,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    hintText: 'Start Conversation',
                    hintStyle:
                        TextStyle(color: Colors.white70.withOpacity(0.5))),
              ),
            ),
          ),

          //Send Button
          hideSendButton
              ? Container():
               GestureDetector(
                  onTap: () {
                    if (messageController.text.isNotEmpty &&
                        messageController.text.trim().isNotEmpty) {
                      onMessageSend(messageController.text, 0);
                      messageController.clear(); //clear
                    }
                  },
                  child: Container(
                    height: 47,
                    width: 47,
                    margin: EdgeInsets.only(right: 5.0),
                    decoration: BoxDecoration(
                        color: Styles.appBarColor, shape: BoxShape.circle),
                    child: Icon(Icons.send, size: 24, color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }

  onMessageSend(String msgContent, int type) {
    // type 0 = text,
    // type 1 = image,
    // type 2 = Emoji

    if (msgContent.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set({
        'username': widget.receiverName,
        'photoUrl': widget.receiverAvatar,
        'sendTo': widget.receiverId,
        'sendBy': currentUserId,
        'msgContent': msgContent,
        'type': type,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    }

    print('$msgContent, type');
  }

  // AppBar defaultAppBar() {
  //   return AppBar(
  //    backgroundColor: Styles.appBarColor,
  //     leading: IconButton(
  //       onPressed: () async{
  //         Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(builder: (context) => HomePage()),
  //             (route) => false);
  //       },
  //       icon: Icon(Icons.chevron_left),
  //     ),
  //     title: Text(widget.receiverName,
  //         style: TextStyle(
  //           fontSize: 17.0,
  //         )),
  //     centerTitle: true,
  //     actions: [
  //       GestureDetector(
  //         onTap: (){
  //           showDialog(context: (context),
  //           builder: (context)=>ChatProfilePicView(
  //             profileImage: widget.receiverAvatar,
  //           ));
  //         },
  //           child: Padding(
  //           padding: EdgeInsets.all(8.0),
  //           child: CircleAvatar(
  //             backgroundColor: Colors.black,
  //             backgroundImage:
  //                 CachedNetworkImageProvider(widget.receiverAvatar),
  //           ),
  //         ),
  //       )
  //     ],
  // );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        leading: IconButton(
          onPressed: () async {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false);
          },
          icon: Icon(Icons.chevron_left),
        ),
        title: Text(widget.receiverName,
            style: TextStyle(
              fontSize: 17.0,
            )),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                  context: (context),
                  builder: (context) => ChatProfilePicView(
                        profileImage: widget.receiverAvatar,
                      ));
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      CachedNetworkImageProvider(widget.receiverAvatar),
                ),

         isOnline? Positioned(
                      top: 25.0,
                      right: 31.0,
                      child: Container(
                          height: 9,
                          width: 9,
                          decoration: BoxDecoration(
                              color: Colors.green[400],
                              shape: BoxShape.circle
                          )
                      )
                  ) : Container(),
                ]
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Messages List
              createMessagesList(),

              //Display Stickers
              isDisplaySticker ? createStickers() : Container(),

              // //Input Field
              createInputField()
            ],
          ),
          
       hideScrollDownwardButton? Container():
        Positioned(
              top: 570.0,
              left: 320.0,
              child: GestureDetector(
                onTap: () {
                  scrollController.animateTo(0.0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300));
                },
                child: Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                        color: Styles.appBarColor, shape: BoxShape.circle),
                    child: Icon(
                      Icons.arrow_downward,
                      size: 20,
                      color: Colors.white,
                    )),
              ))
        ],
      ),
    );
  }
}
