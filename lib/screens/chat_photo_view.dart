import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatPhotoView extends StatefulWidget {
  final String photo;
  ChatPhotoView({this.photo});
  @override
  _ChatPhotoViewState createState() => _ChatPhotoViewState();
}

class _ChatPhotoViewState extends State<ChatPhotoView> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Full Image'),
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