import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class BaseAlertDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final String? yes;
  final String? no;
  final Color? yesColor;
  final Color? noColor;
  final Function? yesOnPressed;
  final Function? noOnPressed;

  const BaseAlertDialog({
    super.key,
    this.title,
    this.content,
    this.yesOnPressed,
    this.noOnPressed,
    this.yes = "Yes",
    this.no = "No",
    this.yesColor = Colors.green,
    this.noColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title!),
      content: content,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      actions: <Widget>[
        RichText(
          text: TextSpan(
              text: yes,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: yesColor,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  yesOnPressed!();
                }),
        ),
        const SizedBox(width: 20),
        RichText(
          // textAlign: TextAlign.left,
          text: TextSpan(
              text: no,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: noColor,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  noOnPressed!();
                }),
        ),
      ],
    );
  }
}
