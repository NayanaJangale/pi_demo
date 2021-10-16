import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoActionMessage extends StatelessWidget {
  final String message;

  const CustomCupertinoActionMessage({this.message});
  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyText1.copyWith(
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
    );
  }
}
