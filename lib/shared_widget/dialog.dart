import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogCustomWidget extends StatelessWidget {
  const DialogCustomWidget({
    Key? key,
    required this.titleColor,
    required this.title,
    required this.content,
    required this.status,
    required this.buttom1,
    this.buttom2,
    required this.func1,
    this.func2,
  }) : super(key: key);
  final Color titleColor;
  final String title;
  final String content;
  final String buttom1;
  final String? buttom2;
  final String status;
  final Function func1;
  final Function? func2;

  @override
  Widget build(BuildContext context) {
    return buttom2 == null
        ? CupertinoAlertDialog(
            title: Text(
              '${title}',
              style: TextStyle(color: titleColor),
            ),
            content: Text('${content}'),
            // ignore: deprecated_member_use
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  func1();
                },
                child: Text(
                  '${buttom1}',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          )
        : CupertinoAlertDialog(
            title: Text(
              '${title}',
              style: TextStyle(color: titleColor),
            ),
            content: Text('${content}'),
            // ignore: deprecated_member_use
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  func1();
                },
                child: Text(
                  '${buttom1}',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  func2!();
                },
                child: Text(
                  '${buttom2}',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
  }
}
