import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class PopupHandler {
  static showSuccessPopup({
    BuildContext context,
    String title,
    String description,
    Function onOkClick,
    Function onCancelClick,
  }) {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.SUCCES,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle2.copyWith(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        btnOkOnPress: onOkClick,
        btnCancelOnPress: onCancelClick)
      ..show();
  }

  static showWarningPopup({
    BuildContext context,
    String title,
    String description,
    Function onOkClick,
    Function onCancelClick,
  }) {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.WARNING,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle2.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        btnOkOnPress: onOkClick,
        btnCancelOnPress: onCancelClick)
      ..show();
  }

  static showQuestionPopup({
    BuildContext context,
    String title,
    String description,
    String okText,
    String cancelText,
    Function onOkClick,
    Function onCancelClick,
  }) {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.QUESTION,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        headerAnimationLoop: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle2.copyWith(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        btnOkText: okText,
        btnOkOnPress: onOkClick,
        btnCancelText: cancelText,
        btnCancelOnPress: onCancelClick)
      ..show();
  }
}
