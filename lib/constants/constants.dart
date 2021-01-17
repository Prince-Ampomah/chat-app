import 'dart:io';
import 'package:chatapp/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';

  var defaultAppBar = AppBar(
    backgroundColor: Styles.appBarColor,
    centerTitle: true,
  );

  var selectedAppbar = AppBar(
      leading: IconButton(
        onPressed: () {},
        icon: Icon(Icons.close),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.delete),
        )
      ],
      backgroundColor: Styles.appBarColor);

  AppBar appBar = defaultAppBar;

  //Opening links
  Future<void> onOpenLink(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(
        link.url,
        universalLinksOnly: true,
         enableJavaScript: true
      );
    } else {
      throw 'Could not launch $link';
    }
  }

class ImageSources{
    File imageAvatar;

    //Get Image Function
    getImage(ImageSource source) async {
      //pick image form the gallery source only
      final PickedFile pickedFile =
      await ImagePicker().getImage(source: source);
      if (pickedFile != null) {

        // call cropImage()
        cropImage(pickedFile.path);

      } else {
        Fluttertoast.showToast(
            msg: 'No Image Selected', gravity: ToastGravity.CENTER);
      }

    }

    //Image Cropper Function
    Future<Null> cropImage(String imagePath) async{
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
        //assign cropped image to image and update state
        imageAvatar = croppedImageFile; //update state
      }
      else{
        //update state
      }
    }


}




