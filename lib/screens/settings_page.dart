import 'dart:io';
import 'package:chatapp/internet_connectivity/internet_connectivity.dart';
import 'package:chatapp/screens/settings_photo_view.dart';
import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:chatapp/style/style.dart';
import 'package:chatapp/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String id = '';
  String username = '';
  String photoUrl = '';
  String aboutMe = '';

  bool isHiddenProfile = false;
  bool isLoading = false;
  bool showNotification = true;

  SharedPreferences preferences;
  TextEditingController userNameTextController;
  TextEditingController aboutMeTextController;

  File imageAvatar;

  @override
  void initState() {
    readFromLocal();
    super.initState();
  }

  readFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.get('id');
    username = preferences.get('username');
    photoUrl = preferences.get('photoUrl');
    aboutMe = preferences.get('aboutMe');

    userNameTextController = TextEditingController(text: username);
    aboutMeTextController = TextEditingController(text: aboutMe);

    print("id: $id");
    print('username: $username');
    print('photoUrl: $photoUrl');
    print('aboutMe :$aboutMe');

    setState(() {});
  }

  toggleEditProfile() {
    setState(() {
      isHiddenProfile = !isHiddenProfile;
    });
  }

  getImage() async {
    final PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageAvatar = File(pickedFile.path);
        isLoading = true;
      });
    } else {
      Fluttertoast.showToast(
          msg: 'No Image Selected', gravity: ToastGravity.CENTER);
    }

    uploadImage();
  }

  uploadImage() async{

    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('profile pics')
        .child(id);
    firebase_storage.UploadTask uploadTask =
        storageReference.putFile(imageAvatar);

    firebase_storage.TaskSnapshot storageTaskSnapshot;

    uploadTask.whenComplete(() {
      print('Completed');
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'when complete error: $error');
      setState(() {
        isLoading = false;
      });
    }).then((value){
      storageTaskSnapshot = value;
      storageTaskSnapshot.ref.getDownloadURL().then((newImage) async{
        photoUrl = newImage;
        print('NEW PHOTO: $photoUrl');

        //Update new photo in fire_store
        FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .update({
          'photoUrl' : photoUrl
        }).then((value) async {
         await preferences.setString('photoUrl', photoUrl);
          setState(() {
            isLoading = false;
            Fluttertoast.showToast(msg: 'Photo Uploaded');
          });

        }, onError: (error){
          Fluttertoast.showToast(msg: 'Error Updating Photo: $error');
          setState(() {
            isLoading = false;
          });
        });

      }, onError: (error) {
        Fluttertoast.showToast(msg: 'Downloading Url Error: $error');
        setState(() {
          isLoading = false;
        });
      });
    }, onError: (error) {
      Fluttertoast.showToast(msg: 'Upload task error: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  updateUserInfo() async{

    //Update User Info in fire_store
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({
      'photoUrl' : photoUrl,
      'username' : username,
      'aboutMe': aboutMe
    }).then((value) async {
      await preferences.setString('photoUrl', photoUrl);
      await preferences.setString('username', username);
      await preferences.setString('aboutMe', aboutMe);
      setState(() {
        isLoading = false;
        Fluttertoast.showToast(msg: 'Updated Successfully!');
        Navigator.pop(context);
      });
    }, onError: (error){
      Fluttertoast.showToast(msg: 'Failed To Update: $error');
      setState(() {
        isLoading = false;
      });
    });


  }

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        elevation: 0.0,
        centerTitle: true,
        title:  Text('Settings',
            style: TextStyle(
              fontSize: 15.0,
            )),
        actions: [
          FlatButton(
              onPressed: updateUserInfo,
              child: Text(
                'UPDATE',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Stack(
                children: [

                  //Photo Widget
                  Align(
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context)
                                =>SettingsPhotoView(photo: photoUrl,)
                            )
                        );
                      },
                      child: Container(
                          height: 150,
                          width: 150,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 0.5, color: Colors.white),
                              shape: BoxShape.circle),
                          child: (imageAvatar == null)
                              ?
                          //load default photo
                          (photoUrl != '')
                              ? Container(
                            height: 150.0,
                            width: 150.0,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CachedNetworkImage(
                              height: 150.0,
                              width: 150.0,
                              fit: BoxFit.contain,
                              imageUrl:  photoUrl,
                              placeholder: (context, url) => Container(
                                  height: 150,
                                  width: 150,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle),
                                  child: circularProgress()),
                            ),
                          )
                              : Container()

                          //display gallery image
                              : Container(
                            height: 150,
                            width: 150,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.file(
                              imageAvatar,
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                          )),
                    ),
                  ),

                  //Loading Widget
                  Positioned(
                      top: 60.0,
                      left: 140.0,
                      child:  isLoading? circularProgress() : Container() ),

                  //Camera Icon Widget
                  Positioned(
                      top: 100.0,
                      left: 190.0,
                      child: GestureDetector(
                        onTap: getImage,
                        child: Container(
                          height: 45,
                          width: 45,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                              color: Styles.appBarColor,
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      )),

                  //Internet Connection Widget

                /*  Positioned(
                      top: 103.0,
                      left: 225.0,
                      child: Container(
                        height: 8,
                        width: 8,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 250, 0, 1.0),
                            border: Border.all(
                                width: 0.5, color: Colors.white),
                            shape: BoxShape.circle),
                      )): SizedBox()*/
                ],
              ),
            ),
            SizedBox(height: 5.0),

            //Edit Profile
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(username.toString()),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: toggleEditProfile,
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),

            //User Details
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                child: isHiddenProfile
                    ? Column(
                  children: [
                    TextFormField(
                        onChanged: (value) {
                          setState(() {
                            username = value;
                          });
                        },
                        controller: userNameTextController,
                        cursorColor: Styles.appBarColor,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'User Name',
                        )),
                    SizedBox(height: 15.0),
                    TextFormField(
                        onChanged: (value) {
                          setState(() {
                            aboutMe = value;
                          });
                        },
                        controller: aboutMeTextController,
                        cursorColor: Styles.appBarColor,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: 'Bio',
                        )),
                  ],
                )
                    : Container(),
              ),
            ),

            //Dark Mode Switcher
            SwitchListTile(
                title: Text('Dark Mode'),
                value: themeChanger.darkTheme,
                onChanged: (value) {
                  themeChanger.toggleTheme();
                }),

          ],
        ),
      ),
    );
  /*  return ChangeNotifierProvider<InternetConnectivity>(
      create: (context) => InternetConnectivity(),
      child: Consumer<InternetConnectivity>(
        builder: (context, InternetConnectivity internetConnectivity, child){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Styles.appBarColor,
              elevation: 0.0,
              centerTitle: true,
              title:  Column(
                children: [
                  SizedBox(height: 10.0),
                  Text('Settings',
                      style: TextStyle(
                        fontSize: 15.0,
                      )),
                  SizedBox(height: 3.0),
                  Text(internetConnectivity.getIsOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 10.0,
                      ))
                ],
              ),
              actions: [
                FlatButton(
                    onPressed: updateUserInfo,
                    child: Text(
                      'UPDATE',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Stack(
                      children: [

                        //Photo Widget
                        Align(
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context)
                                      =>SettingsPhotoView(photo: photoUrl,)
                                  )
                              );
                            },
                            child: Container(
                                height: 150,
                                width: 150,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.5, color: Colors.white),
                                    shape: BoxShape.circle),
                                child: (imageAvatar == null)
                                    ?
                                //load default photo
                                (photoUrl != '')
                                    ? Container(
                                  height: 150.0,
                                  width: 150.0,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: CachedNetworkImage(
                                    height: 150.0,
                                    width: 150.0,
                                    fit: BoxFit.contain,
                                    imageUrl:  photoUrl,
                                    placeholder: (context, url) => Container(
                                        height: 150,
                                        width: 150,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle),
                                        child: circularProgress()),
                                  ),
                                )
                                    : Container()

                                //display gallery image
                                    : Container(
                                  height: 150,
                                  width: 150,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.file(
                                    imageAvatar,
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.contain,
                                  ),
                                )),
                          ),
                        ),

                        //Loading Widget
                        Positioned(
                            top: 60.0,
                            left: 140.0,
                            child:  isLoading? circularProgress() : Container() ),

                        //Camera Icon Widget
                        Positioned(
                            top: 100.0,
                            left: 190.0,
                            child: GestureDetector(
                              onTap: getImage,
                              child: Container(
                                height: 45,
                                width: 45,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    color: Styles.appBarColor,
                                    shape: BoxShape.circle),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            )),

                        //Internet Connection Widget
                        internetConnectivity.getIsOnline?
                        Positioned(
                            top: 103.0,
                            left: 225.0,
                            child: Container(
                              height: 8,
                              width: 8,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 250, 0, 1.0),
                                  border: Border.all(
                                      width: 0.5, color: Colors.white),
                                  shape: BoxShape.circle),
                            )): SizedBox()
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),

                  //Edit Profile
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(username.toString()),
                        SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          onTap: toggleEditProfile,
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  //User Details
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      child: isHiddenProfile
                          ? Column(
                        children: [
                          TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  username = value;
                                });
                              },
                              controller: userNameTextController,
                              cursorColor: Styles.appBarColor,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                hintText: 'User Name',
                              )),
                          SizedBox(height: 15.0),
                          TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  aboutMe = value;
                                });
                              },
                              controller: aboutMeTextController,
                              cursorColor: Styles.appBarColor,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                hintText: 'Bio',
                              )),
                        ],
                      )
                          : Container(),
                    ),
                  ),

                  //Dark Mode Switcher
                  SwitchListTile(
                      title: Text('Dark Mode'),
                      value: themeChanger.darkTheme,
                      onChanged: (value) {
                        themeChanger.toggleTheme();
                      }),

                ],
              ),
            ),
          );
        } ,
      ),
    );*/
  }
}
