import 'package:chatapp/style/style.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsPhotoView extends StatefulWidget {
  final String photo;
  SettingsPhotoView({this.photo});
  @override
  _SettingsPhoto createState() => _SettingsPhoto();
}

class _SettingsPhoto extends State<SettingsPhotoView> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        title: Text('Setting Image'),
        elevation: 0.0,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(
            widget.photo == null? Icon(Icons.person) : widget.photo
          ),
        ),
      ),
    );
  }
}
