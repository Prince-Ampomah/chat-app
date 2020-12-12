import 'package:chatapp/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

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

