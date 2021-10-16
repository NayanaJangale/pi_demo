import 'package:flutter/material.dart';

class CustomTextBox extends StatelessWidget {
  final TextInputType keyboardType;
  final Color colour;
  final TextEditingController controller;
  final IconData icon, suffixIcon;
  final String hintText;
  final int maxLength;
  final Function onFieldSubmitted;
  final FocusNode focusNode;
  final TextInputAction inputAction;

  const CustomTextBox({
    this.keyboardType,
    this.colour,
    this.controller,
    this.icon,
    this.hintText,
    this.maxLength,
    this.onFieldSubmitted,
    this.focusNode,
    this.inputAction,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(primaryColor: this.colour),
      child: new  TextFormField(
        controller: controller,
        focusNode: focusNode,

        decoration: InputDecoration(
          // border: InputBorder.none,
            prefixIcon: new Icon(
              this.icon,
              color: this.colour,
            ),
            hintStyle: TextStyle(
              color: this.colour,
            ),
            filled: true,
            fillColor:  Theme.of(context).secondaryHeaderColor.withOpacity(0.2),
            hintText: hintText),
      )
    );
  }
}
