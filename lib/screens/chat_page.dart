import 'dart:async';
import 'dart:io';
import 'package:chatapp/constants/constants.dart';
import 'package:chatapp/internet_connectivity/internet_connectivity.dart';
import 'package:chatapp/screens/chat_photo_view.dart';
import 'package:chatapp/screens/chat_profile_pic_view.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:chatapp/style/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';

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

  //Boolean Declarations
  bool isLoading;
  bool hideSendButton;
  bool showAudioButton;
  bool hideScrollDownwardButton;
  bool showLongPressedAppBar;

  //String Declarations
  String chatId;
  String currentUserId;

  //Image File Declarations
  File imageFile;
  String imageUrl;

  TextEditingController messageController = TextEditingController();
  FocusNode keyboardFocusNode = FocusNode();
  ScrollController scrollController;
  ScrollController textFieldController;

  @override
  void initState() {
    chatId = '';
    isLoading = false;
    hideScrollDownwardButton = true;
    hideSendButton = true;
    showAudioButton = true;
    showLongPressedAppBar = false;
    keyboardFocusNode.addListener(focusNodeListener);
    scrollController = ScrollController();
    textFieldController = ScrollController();
    readFromLocal();
    super.initState();
  }

  readFromLocal() async {
    preferences = await SharedPreferences.getInstance();
    currentUserId = preferences.getString('id');
    print('currentUserId: $currentUserId');

    //Generate chat id to enable users to chat privately
    if (currentUserId.hashCode <= widget.receiverId.hashCode) {
      chatId = '${currentUserId}_${widget.receiverId}';
      preferences
          .setString('chatId', chatId)
          .then((value) => print('save chatId=> $value'));
    } else {
      chatId = '${widget.receiverId}_$currentUserId';
      preferences
          .setString('chatId', chatId)
          .then((value) => print('save chatId=> $value'));
      print("chatId: $chatId");
    }

    //Update the user whom current user is chatting with
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({"chattingWith": widget.receiverId});

    if(this.mounted){
      setState(() {});
    }
  }

  focusNodeListener() {
    if (keyboardFocusNode.hasFocus) {
      if(this.mounted){
      setState(() {
        hideSendButton = false; //show send Button
      });
      }
    }
  }

  displayImageSourceOptions(){
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0)),
        ),
        context: context,
        builder: (context){
          return Container(
            height: 100.0,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Styles.appBarColor,
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          children: [
                            IconButton(
                                onPressed: (){
                                  getImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.camera_alt, color: Colors.white,)
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Styles.appBarColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            onPressed: (){
                              getImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.image, color: Colors.white,)

                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  getImage(ImageSource source) async {
    PickedFile pickedImage =
        await ImagePicker().getImage(source: source);

    if (pickedImage != null) {
      //crop image after selection
      _imageCropper(pickedImage.path);
    } else {
      Fluttertoast.showToast(
          msg: 'No Image Selected', gravity: ToastGravity.CENTER);
    }

  }

  Future<Null> _imageCropper(String imagePath) async{
    File croppedImageFile = await ImageCropper.cropImage(
        sourcePath: imagePath,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Styles.appBarColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image ',
        )
    );

    if(croppedImageFile != null){
      if(this.mounted){
        setState((){
          imageFile = croppedImageFile;
          isLoading = true;
        });
      }
      else{
        if(this.mounted){
          setState((){
            isLoading = false;
          });
        }
      }
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
      if(this.mounted){
        setState(() {
          isLoading = false;
        });
      }
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
        if(this.mounted){
          setState(() {
            isLoading = false;
          });
        }
      });
    }, onError: (error) {
      Fluttertoast.showToast(msg: 'Storage Task Snapshot Error: $error');
      if(this.mounted){
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Widget streamMessages(BuildContext context) {
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
                    onLongPress: () {},
                    child: createMessageListItem(documentSnapshot, context),
                  );
                }),
          );
        });
  }

  createMessageListItem(
    DocumentSnapshot documentSnapshot,
    BuildContext context,
  ) {
    var getData = documentSnapshot.data();
    final bool isSendByMe = getData['sendBy'] == currentUserId;
    //   bool lengthOfText = getData['msgContent'].toString().length <= 500;
//  final isOnline = Provider.of<InternetConnectivity>(context);

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
                        //Text Container
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: isSendByMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              //Text
                              SelectableLinkify(
                                onOpen: onOpenLink,
                                text: getData['msgContent'].toString(),
                                style: TextStyle(color: Styles.appBarColor),
                                linkStyle: TextStyle(color: Colors.blue),
                              ),

                              //Ticking Icon
                              isSendByMe
                                  ? Icon(Icons.done_all,
                                      size: 13, color: Colors.blue)
                                  : SizedBox(),
                            ],
                          ),
                        ),

                        //Time Container
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
                  )

    );
  }

  createMessagesList(BuildContext context) {
    return Flexible(
        child: chatId == ''
            ? Center(child: circularProgress())
            : streamMessages(context));
  }

  createInputField() {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 5.0,
          ),

          //Input Field
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Styles.appBarColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //Image Button
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(192, 214, 255, 5.0),
                          shape: BoxShape.circle),
                      child: GestureDetector(
                          onTap: displayImageSourceOptions,
                          child: Icon(Icons.image,
                              color: Styles.appBarColor, size: 20)),
                    ),
                  ),

                  //TextField
                  Flexible(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                      child: Scrollbar(
                        controller: textFieldController,
                        thickness: 3.0,
                        radius: Radius.circular(10.0),
                        child: TextField(
                          scrollController: textFieldController,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.newline,
                          textAlign: TextAlign.justify,
                          maxLines: 7,
                          minLines: 1,
                          controller: messageController,
                          focusNode: keyboardFocusNode,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Start Conversation',
                              hintStyle: TextStyle(
                                  color: Colors.white70.withOpacity(0.5))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Send Button
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

  onMessageSend(String msgContent, int type) async {
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
        'chatId': chatId
      }).whenComplete(() {
        FirebaseFirestore.instance.collection('chattedUsers').doc(chatId).set({
          'receiverId': widget.receiverId,
          'receiverName': widget.receiverName,
          'receiverPhoto': widget.receiverAvatar,
          'chatId': chatId,
          'recentMessages': msgContent,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
        }).catchError((onError) {
          print('$onError');
        });
      });
    }
    print('$msgContent, type');
  }

  Future<void> deleteMessage() async {
    return FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection(chatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    bool isMe = currentUserId == widget.receiverId;

    return ChangeNotifierProvider<InternetConnectivity>(
      create: (context) => InternetConnectivity(),
      child: Consumer<InternetConnectivity>(
        builder: (context, InternetConnectivity internetConnectivity, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Styles.appBarColor,
              title: Column(
                children: [
                  Text(widget.receiverName ?? '',
                      style: TextStyle(
                        fontSize: 15.0,
                      )),
                  Text(
                      isMe
                          ? ('${internetConnectivity.getIsOnline ? '' : ''}')
                          : ('${internetConnectivity.getIsOnline ? 'online' : 'last seen'}'),
                      style: TextStyle(
                        fontSize: 15.0,
                      )),
                ],
              ),
              centerTitle: true,
              actions: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: (context),
                        builder: (context) => ChatProfilePicView(
                              profileImage: widget.receiverAvatar ?? '',
                            ));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Stack(children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        backgroundImage:
                            CachedNetworkImageProvider(widget.receiverAvatar),
                      ),
/*                internetConnectivity.getIsOnline
                          ? Positioned(
                          top: 20.0,
                          right: 0.0,
                          left: 33.0,
                          child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 250, 0, 1.0),
                                  border: Border.all(
                                      width: 0.5, color: Colors.white),
                                  shape: BoxShape.circle)))
                          : Container(),*/
                    ]),
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
                    createMessagesList(context),

                    //Input Field
                    createInputField()
                  ],
                ),
                hideScrollDownwardButton
                    ? Container()
                    : Positioned(
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
                                  color: Styles.appBarColor,
                                  shape: BoxShape.circle),
                              child: Icon(
                                Icons.arrow_downward,
                                size: 20,
                                color: Colors.white,
                              )),
                        ))
              ],
            ),
          );
        },
      ),
    );
  }
}

//Rich Text comment
/*RichText(
text: TextSpan(
text: lengthOfText
? getData['msgContent']
.toString()
    .substring(0, 500) +
'...'
: getData['msgContent'],
style: TextStyle(color: Styles.appBarColor),
children: [
TextSpan(
text: lengthOfText ? ' Read More' : '',
style: TextStyle(color: Colors.blue),
recognizer: TapGestureRecognizer()
..onTap = () {
Fluttertoast.showToast(
msg: 'handle read more');
})
]))

 read more comment*/

//Text comment
/*Text(
getData['msgContent'].toString().length <= 200?
getData['msgContent'] :
getData['msgContent'].toString()
    .substring(0, 201) + ' read more',
style: TextStyle(color: Styles.appBarColor),
)

Text(
getData['msgContent'],
style: TextStyle(color: Styles.appBarColor),
),*/

// scroll controller comment
/*
scrollListener(){
     if(scrollController.offset >= scrollController.position.maxScrollExtent
      && !scrollController.position.outOfRange){
         setState(() {
           hideScrollDownwardButton = false;
           Fluttertoast.showToast(msg: 'Reach Bottom');

         });
     }
   }*/
