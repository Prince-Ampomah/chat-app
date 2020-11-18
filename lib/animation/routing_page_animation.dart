import 'package:flutter/material.dart';

class AnimatePageRoute extends PageRouteBuilder{

  final Widget widget;
  final Alignment alignment;
  final Duration duration;
  AnimatePageRoute({this.widget, this.alignment, this.duration})

      : super(
      transitionDuration: duration,
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secAnimation,
          Widget child) {
        animation = CurvedAnimation(parent: animation, curve: Curves.linear);
        return ScaleTransition(
          alignment: alignment,
          scale: animation,
          child: child,
        );
      },
      pageBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secAnimation) {
        return widget;
      }

  );



}