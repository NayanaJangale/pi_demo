import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDropdownList extends StatelessWidget {
  final String selectedText;
  final Function onActionTapped;
  final bool visibilityStatus;
  final IconData prefixIcon;

  CustomDropdownList({
    this.selectedText,
    @required this.onActionTapped,
    @required this.visibilityStatus,
    @required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visibilityStatus ?? true,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onActionTapped,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).accentColor,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Visibility(
                visible: prefixIcon != null,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(
                    prefixIcon,
                    color: Colors.black45,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  selectedText,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
