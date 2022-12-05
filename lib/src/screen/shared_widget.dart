import 'package:flutter/material.dart';

class StatusConnec extends StatefulWidget {
  const StatusConnec({Key? key, required this.Connec}) : super(key: key);

  final Color Connec;
  @override
  State<StatusConnec> createState() => _StatusConnecState();
}

class _StatusConnecState extends State<StatusConnec> {
  Color _colorStatus = Colors.red;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.Connec == true) {
      _colorStatus = Colors.green;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0, right: 22.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: widget.Connec,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          SizedBox(),
        ],
      ),
    );
  }
}
