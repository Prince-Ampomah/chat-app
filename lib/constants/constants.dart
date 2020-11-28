import 'package:chatapp/style/style.dart';
import 'package:flutter/material.dart';

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

