import 'package:flutter/material.dart';
import 'package:pulse_india/components/responsive_ui.dart';

class CustomPasswordField extends StatefulWidget {
  final String hint;
  final int maxlength;
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData icon;
  final Function validation;
  final Function onFieldSubmitted;
  final FocusNode focusNode;

  CustomPasswordField({
    this.hint,
    this.maxlength,
    this.textEditingController,
    this.keyboardType,
    this.icon,
    this.validation,
    this.focusNode,
    this.onFieldSubmitted,
    this.obscureText = false,
  });

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _visible = true;
  double _width;

  double _pixelRatio;

  bool large;

  bool medium;

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      borderRadius: BorderRadius.circular(5.0),
      elevation: large ? 3 : (medium ? 2 : 1),
      child: TextFormField(
        maxLength: widget.maxlength,
        focusNode: widget.focusNode,
        onFieldSubmitted: widget.onFieldSubmitted,
        controller: widget.textEditingController,
        validator: widget.validation,
        keyboardType: widget.keyboardType,
        cursorColor: Theme.of(context).primaryColor,
        style: Theme.of(context).textTheme.bodyText1.copyWith(
              color: Colors.grey[700],
            ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.icon,
            color: Colors.black45,
            //  color: Theme.of(context).primaryColor,
            size: 20,
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _visible = !_visible;
              });
            },
            child: new Icon(
              _visible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              //  color: Theme.of(context).primaryColor,
              color: Colors.black45,
            ),
          ),
          hintText: widget.hint,
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
        obscureText: _visible,
      ),
    );
  }
}
