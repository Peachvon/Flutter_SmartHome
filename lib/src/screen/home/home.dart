// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smarthome/shared_widget/dialog.dart';
import 'package:smarthome/src/models/device_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:smarthome/src/screen/add/add.dart';
import 'package:smarthome/src/screen/home/air/air_screen.dart';
import 'package:smarthome/src/config/theme.dart' as custom_theme;
import 'package:smarthome/src/screen/home/door/door.dart';
import 'package:smarthome/src/service/mqtt_connect/matt_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map> item = [];

  setItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    List<String>? stringValue = prefs.getStringList('item');
    print(stringValue);
    // print(stringValue.length);
    Map? getItemMap;
    if (stringValue != null && stringValue.length != 0) {
      for (var i = 0; i < stringValue.length; i++) {
        getItemMap = jsonDecode(stringValue[i]);
        item.add(getItemMap!);
        //  print(stringValue.length);
      }
    }

    setState(() {});
  }

  dleatDevice(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listItem = [];
    item.removeAt(index);
    print(item.length);
    if (item.length > 0) {
      for (var i = 0; i < item.length; i++) {
        listItem.add(jsonEncode(item[i]));

        //  print(stringValue.length);
      }
      print('$listItem');
      prefs.setStringList('item', listItem);
    } else {
      prefs.remove('item');
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    //disconnectMqtt();
    setItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text(
          'Device',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1.3,
        children: _buildGridList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: custom_theme.Theme.MainTheme,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItem()),
          );
        },
        child: Text(
          '+',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  List<Container> _buildGridList() {
    return List.generate(
      item.length,
      (index) => Container(
        margin: EdgeInsets.all(14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // ignore: prefer_const_literals_to_create_immutables
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset(1, 1),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: InkWell(
          onTap: () {
            if (item[index]['Type'] == '1') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AirScreen(
                    name: item[index]['Name'].toString(),
                    ip: item[index]['IP'].toString(),
                    topic: item[index]['Topic'].toString(),
                    brand: item[index]['Brand'].toString(),
                  ),
                ),
              );
            } else if (item[index]['Type'] == '2') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoorScreen(
                    name: item[index]['Name'].toString(),
                    ip: item[index]['IP'].toString(),
                    topic: item[index]['Topic'].toString(),
                  ),
                ),
              );
            }
          },
          onLongPress: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  void pop() {
                    Navigator.pop(context);
                  }

                  void DL() {
                    dleatDevice(index);
                    Navigator.pop(context);
                  }

                  return DialogCustomWidget(
                    titleColor: Colors.red,
                    title: 'ลบอุปกรณ์',
                    content: 'คุณต้องการลบอุปกรณืหรือไม่?',
                    status: 'error',
                    buttom1: 'ลบ',
                    buttom2: 'ยกเลิก',
                    func1: DL,
                    func2: pop,
                  );
                });
          },
          child: Column(
            children: [
              Spacer(flex: 5),
              if (item[index]['Type'] == '1')
                Icon(
                  Icons.air_outlined,
                  size: 32,
                )
              else
                Icon(
                  Icons.door_back_door,
                  size: 32,
                ),
              Spacer(
                flex: 1,
              ),
              Container(
                alignment: Alignment.center,
                child: FittedBox(
                  child: Text(
                    '${item[index]['Name']}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              Spacer(
                flex: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
