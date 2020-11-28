import 'package:chatapp/shared_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatProfilePicView extends StatelessWidget {
  final String profileImage;
  ChatProfilePicView({this.profileImage});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Material(
           clipBehavior: Clip.hardEdge,
            borderRadius: BorderRadius.circular(5.0),
          child: CachedNetworkImage(
            height: 200,
            width: 200,
            fit: BoxFit.contain,
            imageUrl: profileImage,
            placeholder: (context, url) {
              return chatImagePlaceholder();
            } ,
          ),
      )
    );
  }
}