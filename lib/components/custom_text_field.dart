import 'package:flutter/material.dart';
import 'package:pulse_india/components/responsive_ui.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isElivated;
  final IconData icon;
  double _width;
  double _pixelRatio;
  bool large;
  bool medium;
  bool enable;
  bool autofoucus;
  final int maxLength;
  final Function onFieldSubmitted;
  final FocusNode focusNode;
  final Function validation;

  CustomTextField({
    this.hint,
    this.textEditingController,
    this.keyboardType,
    this.icon,
    this.autofoucus,
    this.validation,
    this.focusNode,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.isElivated,
    this.enable,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      elevation: isElivated == null || isElivated
          ? large
              ? 3
              : (medium ? 2 : 1)
          : 1,
      child: TextFormField(
        maxLength: maxLength,
        focusNode: focusNode,
        autofocus: autofoucus,
        enabled: enable,
        onFieldSubmitted: onFieldSubmitted,
        controller: textEditingController,
        validator: validation,
        keyboardType: keyboardType,
        cursorColor: Theme.of(context).primaryColor,
        style: Theme.of(context).textTheme.bodyText1.copyWith(
              color: Colors.grey[700],
            ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.black45,
            //     color: Theme.of(context).primaryColor,
            size: 20,
          ),
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyText2.copyWith(
                color: Colors.grey[400],
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              color: Theme.of(context).accentColor,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              color: Theme.of(context).accentColor,
              width: 1,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              color: Theme.of(context).accentColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              color: Theme.of(context).accentColor,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
